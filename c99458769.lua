--暗黒界の魔神 レイン
-- 效果：
-- ①：这张卡被对方的效果从手卡丢弃去墓地的场合发动。这张卡特殊召唤。
-- ②：这张卡的①的效果特殊召唤成功的场合发动。从以下效果选1个适用。
-- ●对方场上的怪兽全部破坏。
-- ●对方场上的魔法·陷阱卡全部破坏。
function c99458769.initial_effect(c)
	-- ①：这张卡被对方的效果从手卡丢弃去墓地的场合发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99458769,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c99458769.spcon)
	e1:SetTarget(c99458769.sptg)
	e1:SetOperation(c99458769.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果特殊召唤成功的场合发动。从以下效果选1个适用。●对方场上的怪兽全部破坏。●对方场上的魔法·陷阱卡全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99458769,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c99458769.descon)
	e2:SetTarget(c99458769.destg)
	e2:SetOperation(c99458769.desop)
	c:RegisterEffect(e2)
end
-- 判断①效果的发动条件：这张卡此前位于手牌、因对方发动的效果被丢弃去墓地，且丢弃前由自己控制。
function c99458769.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,0x4040)==0x4040 and rp==1-tp
		and e:GetHandler():IsPreviousControler(tp)
end
-- ①效果发动时无取对象，确认可以发动后将特殊召唤自身设为操作信息。
function c99458769.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次连锁将把这张卡特殊召唤的操作信息，数量为1，供时点检测和连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理时，若这张卡仍与效果关联，则将其特殊召唤。
function c99458769.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以自身效果作为召唤方式、正面表示特殊召唤到其持有者（自己）场上。
		Duel.SpecialSummon(e:GetHandler(),SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断②效果的发动条件：这张卡是以①效果成功特殊召唤的场合。
function c99458769.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- ②效果发动时，统计对方怪兽区和魔陷区的卡片数，计算预计破坏数量，若存在可破坏的卡则设置破坏操作信息。
function c99458769.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 统计对方场上主要怪兽区的卡牌数量。
	local c1=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 统计对方场上魔法·陷阱区的卡牌数量。
	local c2=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_SZONE,nil)
	if (c1>c2 and c2~=0) or c1==0 then c1=c2 end
	if c1~=0 then
		-- 获取对方场上所有怪兽和魔法·陷阱卡作为可能破坏对象。
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		-- 设置本次连锁将破坏对方场上卡片，预计破坏数量为c1，便于对手连锁响应。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,c1,0,0)
	end
end
-- ②效果处理时，获取对方怪兽区和魔陷区的全部卡；仅一方有卡则直接破坏该方全部，若双方都有卡则让玩家选择破坏怪兽全部或魔法·陷阱卡全部。
function c99458769.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上怪兽区的全部卡。
	local g1=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 获取对方场上魔法·陷阱区的全部卡。
	local g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_SZONE,nil)
	if g1:GetCount()>0 or g2:GetCount()>0 then
		if g1:GetCount()==0 then
			-- 对方场上无怪兽，适用破坏对方场上全部魔法·陷阱卡，将g2全部破坏。
			Duel.Destroy(g2,REASON_EFFECT)
		elseif g2:GetCount()==0 then
			-- 对方场上无魔法·陷阱卡，适用破坏对方场上全部怪兽，将g1全部破坏。
			Duel.Destroy(g1,REASON_EFFECT)
		else
			-- 发出选择提示消息，让当前玩家从待选效果中作出选择。
			Duel.Hint(HINT_SELECTMSG,tp,0)
			-- 弹出选项：0为“对方场上的怪兽全部破坏”，1为“对方场上的魔法·陷阱卡全部破坏”，并返回所选序号。
			local ac=Duel.SelectOption(tp,aux.Stringid(99458769,2),aux.Stringid(99458769,3))  --"对方场上的怪兽全部破坏/对方场上的魔法·陷阱卡全部破坏"
			-- 若选择0，将对方场上全部怪兽破坏。
			if ac==0 then Duel.Destroy(g1,REASON_EFFECT)
			-- 若选择1，将对方场上全部魔法·陷阱卡破坏。
			else Duel.Destroy(g2,REASON_EFFECT) end
		end
	end
end
