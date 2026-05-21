--シャルル大帝
-- 效果：
-- 有装备卡装备的9星「焰圣骑士帝-查理」1只
-- ①：这张卡连接召唤的场合，以自己墓地1只「焰圣骑士帝-查理」为对象才能发动。这张卡当作和那张卡同名卡使用，得到相同效果。那之后，作为对象的怪兽当作攻击力上升500的装备魔法卡使用给这张卡装备。
-- ②：1回合1次，魔法·陷阱卡的效果发动时，从自己的手卡·场上（表侧表示）把1张装备魔法卡送去墓地才能发动。那个发动无效并破坏。
local s,id,o=GetID()
-- 初始化函数，注册连接召唤手续、①效果（复制同名卡效果并装备）和②效果（无效魔陷发动并破坏）
function s.initial_effect(c)
	-- 在卡片中记录提及了「焰圣骑士帝-查理」的卡片密码
	aux.AddCodeList(c,77656797)
	c:EnableReviveLimit()
	-- 注册连接召唤手续，需要1个满足过滤条件的怪兽作为素材
	aux.AddLinkProcedure(c,s.matfilter,1,1)
	-- ①：这张卡连接召唤的场合，以自己墓地1只「焰圣骑士帝-查理」为对象才能发动。这张卡当作和那张卡同名卡使用，得到相同效果。那之后，作为对象的怪兽当作攻击力上升500的装备魔法卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"复制卡名和效果"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.copycon)
	e1:SetTarget(s.copytg)
	e1:SetOperation(s.copyop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，魔法·陷阱卡的效果发动时，从自己的手卡·场上（表侧表示）把1张装备魔法卡送去墓地才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"发动无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
-- 连接素材过滤条件：等级9且卡名为「焰圣骑士帝-查理」且有装备卡装备的怪兽
function s.matfilter(c)
	return c:IsLevel(9) and c:IsLinkCode(77656797) and c:GetEquipCount()>0
end
-- ①效果发动条件：这张卡连接召唤成功
function s.copycon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- ①效果对象过滤条件：墓地中的「焰圣骑士帝-查理」且可以作为装备卡装备
function s.copyfilter(c,tp)
	return c:IsCode(77656797) and c:GetOriginalType()&TYPE_EFFECT==TYPE_EFFECT
		and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- ①效果的靶向/发动准备阶段，检查魔法与陷阱区域是否有空位，并选择墓地的「焰圣骑士帝-查理」为对象
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.copyfilter(chkc,tp) end
	-- 检查自己场上是否有可用的魔法与陷阱区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己墓地是否存在可以作为对象的「焰圣骑士帝-查理」
		and Duel.IsExistingTarget(s.copyfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择要作为效果对象的目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择墓地1只「焰圣骑士帝-查理」作为效果对象
	local g=Duel.SelectTarget(tp,s.copyfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置效果处理信息：有1张卡将离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g:GetFirst(),1,0,0)
end
-- ①效果的实际处理：复制对象怪兽的卡名和效果，然后将其作为装备卡装备给这张卡，并使其攻击力上升500
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		local code=tc:GetOriginalCode()
		-- 这张卡当作和那张卡同名卡使用
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		if tc:GetOriginalType()&TYPE_EFFECT==TYPE_EFFECT then
			c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD)
		end
		-- 检查魔法与陷阱区域是否有空位，且对象怪兽可以合法放置在场上
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and tc:CheckUniqueOnField(tp) and not tc:IsForbidden() then
			-- 中断当前效果处理，使后续的装备处理与前面的复制效果不视为同时处理
			Duel.BreakEffect()
			-- 将对象怪兽作为装备卡装备给这张卡，若装备失败则结束处理
			if not Duel.Equip(tp,tc,c) then return end
			e:SetLabelObject(tc)
			-- 当作装备魔法卡使用给这张卡装备
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetValue(s.eqlimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 攻击力上升500
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(500)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
end
-- 限制装备卡只能装备给当前效果的发动者（即这张卡）
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
-- ②效果发动条件：魔法·陷阱卡的效果发动时，且这张卡不在战斗破坏确定状态
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 且该连锁的发动可以被无效
		and Duel.IsChainNegatable(ev)
end
-- ②效果的Cost过滤条件：手卡或场上表侧表示的装备魔法卡
function s.cfilter(c)
	return c:GetType()&(TYPE_SPELL+TYPE_EQUIP)==TYPE_SPELL+TYPE_EQUIP and c:IsAbleToGraveAsCost() and c:IsFaceupEx()
end
-- ②效果的Cost处理：从手卡或场上表侧表示将1张装备魔法卡送去墓地
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或场上是否存在可送去墓地的装备魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1张手卡或场上表侧表示的装备魔法卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的卡作为发动Cost送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②效果的靶向/发动准备阶段，设置无效与破坏的操作信息
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息：使该发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置效果处理信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ②效果的实际处理：使魔法·陷阱卡的效果发动无效并破坏
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 成功使发动无效，且该卡在连锁中关系成立
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
