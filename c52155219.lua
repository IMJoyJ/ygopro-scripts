--転生炎獣の炎陣
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●从卡组把1只「转生炎兽」怪兽加入手卡。
-- ●以用和自身同名的怪兽为素材作连接召唤的自己场上1只「转生炎兽」连接怪兽为对象才能发动。这个回合，那只连接怪兽不受自身以外的怪兽的效果影响。
function c52155219.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,52155219+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c52155219.target)
	e1:SetOperation(c52155219.activate)
	c:RegisterEffect(e1)
	if not c52155219.global_check then
		c52155219.global_check=true
		-- 效果原文内容：①：可以从以下效果选择1个发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
		ge1:SetCode(EFFECT_MATERIAL_CHECK)
		ge1:SetValue(c52155219.valcheck)
		-- 将效果注册给全局环境
		Duel.RegisterEffect(ge1,0)
	end
end
-- 检查连接召唤时是否使用了同名怪兽作为素材，并为该怪兽标记flag
function c52155219.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsLinkCode,1,nil,c:GetCode()) then
		c:RegisterFlagEffect(52155219,RESET_EVENT+0x4fe0000,0,1)
	end
end
-- 检索满足条件的「转生炎兽」怪兽（类型为怪兽且可加入手牌）
function c52155219.thfilter(c)
	return c:IsSetCard(0x119) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 筛选满足条件的「转生炎兽」连接怪兽（表侧表示、连接召唤、拥有flag）
function c52155219.immfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x119) and c:IsSummonType(SUMMON_TYPE_LINK) and c:GetFlagEffect(52155219)~=0
end
-- 处理效果选择，判断是否可以发动两种效果并进行选项选择
function c52155219.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c52155219.immfilter(chkc) end
	-- 检查卡组中是否存在满足条件的「转生炎兽」怪兽
	local b1=Duel.IsExistingMatchingCard(c52155219.thfilter,tp,LOCATION_DECK,0,1,nil)
	-- 检查自己场上是否存在满足条件的「转生炎兽」连接怪兽
	local b2=Duel.IsExistingTarget(c52155219.immfilter,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 玩家选择“卡组检索”或“效果抗性”选项
		op=Duel.SelectOption(tp,aux.Stringid(52155219,0),aux.Stringid(52155219,1))  --"卡组检索/效果抗性"
	elseif b1 then
		-- 玩家选择“卡组检索”选项
		op=Duel.SelectOption(tp,aux.Stringid(52155219,0))  --"卡组检索"
	else
		-- 玩家选择“效果抗性”选项
		op=Duel.SelectOption(tp,aux.Stringid(52155219,1))+1  --"效果抗性"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:SetProperty(0)
		-- 设置操作信息为将1张卡从卡组加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(0)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 提示玩家选择表侧表示的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 选择满足条件的「转生炎兽」连接怪兽作为对象
		Duel.SelectTarget(tp,c52155219.immfilter,tp,LOCATION_MZONE,0,1,1,nil)
	end
end
-- 处理效果发动，根据选择的选项执行不同操作
function c52155219.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==0 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择1张满足条件的「转生炎兽」怪兽
		local g=Duel.SelectMatchingCard(tp,c52155219.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	else
		-- 获取当前连锁的目标卡
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 效果原文内容：●以用和自身同名的怪兽为素材作连接召唤的自己场上1只「转生炎兽」连接怪兽为对象才能发动。这个回合，那只连接怪兽不受自身以外的怪兽的效果影响。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetValue(c52155219.efilter)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
-- 设置效果值，使该效果仅对来自其他怪兽的怪兽效果无效
function c52155219.efilter(e,re)
	return e:GetHandler()~=re:GetOwner() and re:IsActiveType(TYPE_MONSTER)
end
