--大精霊機巧軍－ペンデュラム・ルーラー
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。这张卡回到额外卡组。那之后，可以从自己的卡组·额外卡组（表侧）把1只7星灵摆怪兽加入手卡。
-- 【怪兽效果】
-- 7星以上的灵摆怪兽＋灵摆怪兽
-- 这个卡名的③的怪兽效果1回合可以使用最多2次。
-- ①：场上的这张卡不会被效果破坏。
-- ②：只要这张卡在怪兽区域存在，除不持有等级的灵摆怪兽外对方怪兽不能攻击。
-- ③：把自己场上1只怪兽解放，以对方场上1张卡为对象才能发动。那张卡破坏，给与对方1600伤害。
-- ④：1回合1次，自己主要阶段才能发动。这张卡在自己的灵摆区域放置。
local s,id,o=GetID()
-- 初始化函数，注册融合、灵摆以及怪兽效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤的手续，需要7星以上的灵摆怪兽和灵摆怪兽作为素材
	aux.AddFusionProcMix(c,true,true,s.matfilter1,s.matfilter2)
	-- 为卡片注册灵摆怪兽属性，此处设置为不直接注册卡的发动效果
	aux.EnablePendulumAttribute(c,false)
	-- ①：自己主要阶段才能发动。这张卡回到额外卡组。那之后，可以从自己的卡组·额外卡组（表侧）把1只7星灵摆怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回到额外卡组"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.ptg)
	e1:SetOperation(s.pop)
	c:RegisterEffect(e1)
	-- ①：场上的这张卡不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，除不持有等级的灵摆怪兽外对方怪兽不能攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(s.atktg)
	c:RegisterEffect(e3)
	-- ③：把自己场上1只怪兽解放，以对方场上1张卡为对象才能发动。那张卡破坏，给与对方1600伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(2,id+o)
	e4:SetCost(s.descost)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
	-- ④：1回合1次，自己主要阶段才能发动。这张卡在自己的灵摆区域放置。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))  --"在灵摆区域放置"
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(s.pztg)
	e5:SetOperation(s.pzop)
	c:RegisterEffect(e5)
end
-- 融合素材过滤函数1：7星以上的灵摆怪兽
function s.matfilter1(c)
	return c:IsType(TYPE_PENDULUM) and c:IsLevelAbove(7)
end
-- 融合素材过滤函数2：灵摆怪兽
function s.matfilter2(c)
	return c:IsType(TYPE_PENDULUM)
end
-- 检索/加手过滤函数：7星的灵摆怪兽
function s.thfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsLevel(7) and c:IsAbleToHand()
		and c:IsFaceupEx()
end
-- 灵摆效果①的发动检测与效果分类注册函数
function s.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtra() end
	-- 设置操作信息：从卡组或额外卡组将卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 灵摆效果①的处理函数
function s.pop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否正常结算连锁，并执行回到额外卡组的处理
	if c:IsRelateToChain() and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
		and c:IsLocation(LOCATION_EXTRA)
		-- 检查自己的卡组或额外卡组中是否存在满足检索条件的7星灵摆怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil)
		-- 询问玩家是否要将怪兽加入手牌
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把怪兽加入手卡？"
		-- 显示请选择要加入手牌的卡的系统提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择1只满足条件的7星灵摆怪兽
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
		if #g>0 then
			-- 中断当前效果，使后续的加入手卡处理与回到额外卡组的处理视为不同时处理
			Duel.BreakEffect()
			-- 将选择的怪兽加入手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 判定不能攻击的怪兽的过滤函数：除不带有等级的灵摆怪兽以外的对方怪兽
function s.atktg(e,c)
	return not (c:IsType(TYPE_PENDULUM) and c:GetLevel()==0)
end
-- 破坏目标过滤条件判定函数：排除当前准备解放的怪兽本身
function s.desfilter(c,rc)
	return c:GetEquipTarget()~=rc and c~=rc
end
-- 解放怪兽的过滤条件判定函数：选中的被解放怪兽在解放后必须还有其他可破坏的对方场上卡片
function s.costfilter(c,tp)
	-- 判断对方场上是否存在可以被破坏的目标卡片
	return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_ONFIELD,1,c,c)
end
-- 怪兽效果③的发动Cost处理函数
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在可以被解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.costfilter,1,nil,tp) end
	-- 选择场上1只可解放的怪兽
	local g=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,nil,tp)
	-- 解放选择的怪兽
	Duel.Release(g,REASON_COST)
end
-- 怪兽效果③的目标选择与效果分类注册函数
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 判断对方场上是否存在可以被破坏的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示请选择要破坏的卡的系统提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡片作为破坏的目标
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设定效果伤害的承受玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设定伤害数值参数为1600
	Duel.SetTargetParam(1600)
	-- 设置操作信息：破坏目标卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：给与对方1600伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1600)
end
-- 怪兽效果③的效果处理函数
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选择的破坏目标卡片
	local tc=Duel.GetFirstTarget()
	-- 若目标卡仍在场上，则执行破坏
	if tc:IsRelateToChain() and tc:IsOnField() and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 获取效果设定的伤害对象玩家和伤害数值参数
		local p,dam=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		if dam>0 then
			-- 给与对方玩家指定数值的伤害
			Duel.Damage(p,dam,REASON_EFFECT)
		end
	end
end
-- 怪兽效果④的发动检测与目标判定函数
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查灵摆区域是否有空位可用于放置
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and e:GetHandler():IsType(TYPE_PENDULUM) end
end
-- 怪兽效果④的效果处理函数
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡移动/放置到自己的灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
