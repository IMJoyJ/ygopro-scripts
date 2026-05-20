--ヘビーメタルフォーゼ・アマルガム
-- 效果：
-- 「炼装」怪兽2只
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡被效果从怪兽区域送去墓地的场合，可以从以下效果选择1个发动。
-- ●以自己场上1只「炼装」怪兽为对象才能发动。这张卡当作攻击力上升1000的装备卡使用给那只怪兽装备。
-- ●以自己场上1张「炼装」卡为对象才能发动。那张卡破坏，这张卡特殊召唤。
function c61728808.initial_effect(c)
	-- 添加连接召唤手续：用2只「炼装」怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xe1),2,2)
	c:EnableReviveLimit()
	-- ①：这张卡被效果从怪兽区域送去墓地的场合，可以从以下效果选择1个发动。●以自己场上1只「炼装」怪兽为对象才能发动。这张卡当作攻击力上升1000的装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61728808,0))  --"这张卡当作装备卡装备"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,61728808)
	e1:SetCondition(c61728808.condition)
	e1:SetTarget(c61728808.eqtg)
	e1:SetOperation(c61728808.eqop)
	c:RegisterEffect(e1)
	-- ①：这张卡被效果从怪兽区域送去墓地的场合，可以从以下效果选择1个发动。●以自己场上1张「炼装」卡为对象才能发动。那张卡破坏，这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61728808,1))  --"这张卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,61728808)
	e2:SetCondition(c61728808.condition)
	e2:SetTarget(c61728808.sptg)
	e2:SetOperation(c61728808.spop)
	c:RegisterEffect(e2)
end
-- 判定发动条件：这张卡被效果从怪兽区域送去墓地，且可以放置在场上
function c61728808.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- 过滤条件：自己场上表侧表示的「炼装」怪兽
function c61728808.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe1)
end
-- 装备效果的发动准备与判定
function c61728808.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c61728808.eqfilter(chkc) end
	-- 判定自己魔陷区是否有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判定自己场上是否存在可以作为装备对象的表侧表示「炼装」怪兽
		and Duel.IsExistingTarget(c61728808.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的「炼装」怪兽作为效果对象
	Duel.SelectTarget(tp,c61728808.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：涉及墓地卡片移动
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 装备效果的处理：将此卡作为装备卡装备给目标怪兽，并使其攻击力上升1000
function c61728808.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查魔陷区空格、对象怪兽的控制权、表示形式以及是否仍与效果相关，不满足则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not tc:IsControler(tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	if not c:CheckUniqueOnField(tp) or c:IsForbidden() then return end
	-- 将此卡作为装备卡装备给目标怪兽，若装备失败则结束处理
	if not Duel.Equip(tp,c,tc) then return end
	-- 给那只怪兽装备
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c61728808.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 攻击力上升1000
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 限制此卡只能装备给作为对象的那只怪兽
function c61728808.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 过滤条件：自己场上表侧表示的「炼装」卡，且该卡被破坏后能腾出怪兽区域空格
function c61728808.desfilter(c,tp)
	-- 判定卡片是否为表侧表示的「炼装」卡，且该卡离开场上后自己场上是否有可用于特殊召唤的怪兽区域
	return c:IsFaceup() and c:IsSetCard(0xe1) and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤效果的发动准备与判定
function c61728808.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c61728808.desfilter(chkc,tp) end
	-- 判定自己场上是否存在可以作为破坏对象的表侧表示「炼装」卡
	if chk==0 then return Duel.IsExistingTarget(c61728808.desfilter,tp,LOCATION_ONFIELD,0,1,nil,tp)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张表侧表示的「炼装」卡作为效果对象
	local g=Duel.SelectTarget(tp,c61728808.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 设置操作信息：破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理：破坏目标卡，并将此卡特殊召唤
function c61728808.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象卡
	local tc=Duel.GetFirstTarget()
	-- 判定对象卡是否仍与效果相关，并将其用效果破坏，若破坏成功则继续处理
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			-- 将此卡在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
