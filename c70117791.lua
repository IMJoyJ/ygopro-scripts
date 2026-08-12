--爆撃獣ファイヤ・ボンバー
-- 效果：
-- 机械族怪兽＋炎族怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。对方场上的攻击力1900以下的怪兽全部破坏。
-- ②：这张卡被送去墓地的场合，以对方场上1只攻击力1900以下的怪兽为对象才能发动。那只怪兽破坏，给与对方那个原本攻击力数值的伤害。
local s,id,o=GetID()
-- 注册卡片的初始化效果，包括苏生限制、融合素材设定、以及①和②效果的创建与注册。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为机械族怪兽和炎族怪兽各1只。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),aux.FilterBoolFunction(Card.IsRace,RACE_PYRO),true)
	-- ①：这张卡特殊召唤的场合才能发动。对方场上的攻击力1900以下的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"怪兽破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合，以对方场上1只攻击力1900以下的怪兽为对象才能发动。那只怪兽破坏，给与对方那个原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"取对象破坏"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.destg2)
	e2:SetOperation(s.desop2)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示且攻击力在1900以下的怪兽。
function s.desfilter(c)
	return c:IsFaceup() and c:IsAttackBelow(1900)
end
-- ①效果的发动准备与合法性检测（Target函数），检查是否存在符合条件的怪兽并设置破坏操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只表侧表示且攻击力在1900以下的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有表侧表示且攻击力在1900以下的怪兽。
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置破坏操作信息，包含要破坏的怪兽组及其数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- ①效果的处理函数（Operation函数），获取符合条件的怪兽并将其全部破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上所有表侧表示且攻击力在1900以下的怪兽。
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 因效果破坏获取到的怪兽组。
	Duel.Destroy(sg,REASON_EFFECT)
end
-- ②效果的发动准备与合法性检测（Target函数），进行取对象操作，并设置破坏与伤害的操作信息。
function s.destg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.desfilter(chkc) end
	-- 检查对方场上是否存在至少1只可以作为对象的、表侧表示且攻击力在1900以下的怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让发动效果的玩家选择对方场上1只符合条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置破坏操作信息，包含选中的对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	if math.max(0,g:GetFirst():GetTextAttack())>0 then
		-- 设置伤害操作信息，准备给与对方玩家伤害。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
	end
end
-- ②效果的处理函数（Operation函数），破坏对象怪兽并给与对方其原本攻击力数值的伤害。
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与效果相关、是否仍在怪兽区，并尝试将其因效果破坏。
	if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		local atk=tc:GetTextAttack()
		if atk>0 then
			-- 因效果给与对方玩家等同于该怪兽原本攻击力数值的伤害。
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
