--音響戦士ロックス
-- 效果：
-- ←10 【灵摆】 10→
-- 这个卡名的①的灵摆效果1回合只能使用1次。
-- ①：自己·对方的准备阶段才能发动。从自己的额外卡组把1只表侧表示的灵摆怪兽加入手卡。
-- ②：对方怪兽的攻击宣言时才能发动。那只怪兽和这张卡破坏。
-- 【怪兽效果】
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。从自己的额外卡组把1只表侧表示的灵摆怪兽加入手卡。
-- ②：自己的场地区域有「音响放大器」存在的场合才能发动。选场上1张卡破坏。
-- ③：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
local s,id,o=GetID()
-- 初始化卡片效果，注册代码列表、同调召唤手续、灵摆属性、设置5个效果
function c24070330.initial_effect(c)
	-- 记录该卡拥有「音响放大器」的卡名
	aux.AddCodeList(c,75304793)
	-- 设置该卡为1只调整+调整以外的怪兽的同调召唤手续
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 为该卡添加灵摆怪兽属性，不注册灵摆卡的发动效果
	aux.EnablePendulumAttribute(c,false)
	-- ①：自己·对方的准备阶段才能发动。从自己的额外卡组把1只表侧表示的灵摆怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24070330,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,24070330)
	e1:SetTarget(c24070330.thtg)
	e1:SetOperation(c24070330.thop)
	c:RegisterEffect(e1)
	-- ②：对方怪兽的攻击宣言时才能发动。那只怪兽和这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24070330,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(c24070330.pdcon)
	e2:SetTarget(c24070330.pdtg)
	e2:SetOperation(c24070330.pdop)
	c:RegisterEffect(e2)
	-- ①：这张卡特殊召唤成功的场合才能发动。从自己的额外卡组把1只表侧表示的灵摆怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(24070330,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,24070330+o)
	e3:SetTarget(c24070330.thtg)
	e3:SetOperation(c24070330.thop)
	c:RegisterEffect(e3)
	-- ②：自己的场地区域有「音响放大器」存在的场合才能发动。选场上1张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(24070330,3))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,24070330+o*2)
	e4:SetCondition(c24070330.descon)
	e4:SetTarget(c24070330.destg)
	e4:SetOperation(c24070330.desop)
	c:RegisterEffect(e4)
	-- ③：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(24070330,4))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(c24070330.pencon)
	e5:SetTarget(c24070330.pentg)
	e5:SetOperation(c24070330.penop)
	c:RegisterEffect(e5)
end
-- 检索满足条件的灵摆怪兽（表侧表示、能加入手牌）
function c24070330.thfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 设置效果处理时的条件检查，确认是否有满足条件的灵摆怪兽
function c24070330.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件检查：确认是否有满足条件的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c24070330.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁操作信息：将1张灵摆怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 处理效果：选择并加入手牌
function c24070330.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的灵摆怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c24070330.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的灵摆怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到加入手牌的灵摆怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断攻击方是否为对方
function c24070330.pdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 攻击方不是自己时触发
	return Duel.GetAttacker():GetControler()~=tp
end
-- 设置攻击宣言时的效果处理条件和目标
function c24070330.pdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件检查：攻击怪兽是否参与战斗
	if chk==0 then return Duel.GetAttacker():IsRelateToBattle() end
	-- 设置攻击怪兽为效果目标
	Duel.SetTargetCard(Duel.GetAttacker())
	-- 设置连锁操作信息：破坏攻击怪兽和自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Group.FromCards(e:GetHandler(),Duel.GetAttacker()),2,0,0)
end
-- 处理效果：破坏攻击怪兽和自身
function c24070330.pdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取攻击怪兽
	local tc=Duel.GetFirstTarget()
	local g=Group.FromCards(c,tc):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==2 then
		-- 破坏攻击怪兽和自身
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 判断场地是否存在「音响放大器」
function c24070330.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 场地存在「音响放大器」时触发
	return Duel.IsEnvironment(75304793,tp,LOCATION_FZONE)
end
-- 设置破坏效果的处理条件和目标
function c24070330.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件检查：场上是否存在至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有卡的集合
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息：破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 处理效果：选择并破坏场上卡
function c24070330.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上要破坏的卡
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 显示选中卡的动画效果
		Duel.HintSelection(g)
		-- 破坏选中的卡
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 判断该卡是否从怪兽区域被破坏
function c24070330.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 设置灵摆区域放置效果的处理条件
function c24070330.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件检查：玩家的灵摆区域是否有空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 处理效果：将该卡移动到灵摆区域
function c24070330.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡移动到玩家的灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
