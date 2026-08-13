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
-- 为这张卡注册全部效果：同调召唤手续、灵摆属性、两个灵摆效果（准备阶段回手/攻击宣言破坏）和三个怪兽效果（特殊召唤回手/有音响放大器时选1张破坏/被破坏时放置灵摆区），并设置各效果的条件、目标、操作与次数限制。
function c24070330.initial_effect(c)
	-- 将卡号75304793（「音响放大器」）登记为此卡上记载的卡名，用于后续判定自己的场地区域是否存在「音响放大器」。
	aux.AddCodeList(c,75304793)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 使这张卡获得灵摆怪兽属性（可作为灵摆卡发动/放置灵摆区），但不注册灵摆卡“卡的发动”的效果。
	aux.EnablePendulumAttribute(c,false)
	-- ①：自己·对方的准备阶段才能发动。从自己的额外卡组把1只表侧表示的灵摆怪兽加入手卡。（这个卡名的①的灵摆效果1回合只能使用1次。）
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
	-- ①：这张卡特殊召唤成功的场合才能发动。从自己的额外卡组把1只表侧表示的灵摆怪兽加入手卡。（这个卡名的①的怪兽效果1回合只能使用1次。）
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
	-- ②：自己的场地区域有「音响放大器」存在的场合才能发动。选场上1张卡破坏。（这个卡名的②的怪兽效果1回合只能使用1次。）
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
-- 定义回手效果的过滤器：额外卡组中表侧表示的灵摆怪兽且能够加入手卡。
function c24070330.thfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 回手效果的发动条件和操作信息设置：确认额外卡组存在符合条件的卡，并声明将1张卡从额外卡组加入手卡。
function c24070330.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的额外卡组是否存在至少1张满足回手过滤器（表侧灵摆且能加入手卡）的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c24070330.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置效果处理信息：本次效果将把1张持有者为自己、位于额外卡组的卡加入手卡（具体卡在处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 回手效果的实际处理：玩家从自己的额外卡组选择1张符合条件的表侧灵摆怪兽加入手卡，并让对手确认。
function c24070330.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择框提示，让该玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从自己的额外卡组中选出1张满足回手过滤器的卡。
	local g=Duel.SelectMatchingCard(tp,c24070330.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对手确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 灵摆效果②的发动条件：检测到攻击怪兽的控制者不是自己（即对方怪兽攻击宣言）。
function c24070330.pdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击宣言的怪兽控制者不是自己，满足对方怪兽攻击宣言条件。
	return Duel.GetAttacker():GetControler()~=tp
end
-- 攻击宣言破坏效果的发动条件和对象设置：确认攻击怪兽仍与战斗相关，将其设为对象，并设置破坏这张卡和攻击怪兽的操作信息。
function c24070330.pdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查攻击怪兽是否仍与战斗相关（防止其已离场导致无法取对象）。
	if chk==0 then return Duel.GetAttacker():IsRelateToBattle() end
	-- 将攻击怪兽设定为当前连锁的效果对象。
	Duel.SetTargetCard(Duel.GetAttacker())
	-- 设置破坏操作信息：将这张卡和攻击怪兽作为可能破坏的2张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Group.FromCards(e:GetHandler(),Duel.GetAttacker()),2,0,0)
end
-- 破坏处理：将这张卡与攻击怪兽组成组，保留仍与效果相关的卡，若两者都在则一并破坏。
function c24070330.pdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的第一个对象（即攻击怪兽）。
	local tc=Duel.GetFirstTarget()
	local g=Group.FromCards(c,tc):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==2 then
		-- 将这张卡和攻击怪兽以效果原因破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 怪兽效果②的发动条件：自己的场地区域存在「音响放大器」。
function c24070330.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的场地魔法区域内是否有卡号75304793（「音响放大器」）适用中。
	return Duel.IsEnvironment(75304793,tp,LOCATION_FZONE)
end
-- 破坏效果的目标检测：场上存在至少1张可破坏的卡时允许发动，并设置操作信息为从场上选1张破坏。
function c24070330.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方场上是否存在至少1张卡。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取双方场上的所有卡，作为操作信息中可能被破坏的对象集合。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置破坏操作信息：可能破坏的对象为双方场上所有卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏处理：玩家从双方场上选择1张卡并破坏，同时显示选择动画。
function c24070330.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择框提示，让该玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家从双方场上选择1张卡。
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 手动画出选中卡的被选为对象动画，并记录这些卡被选为对象。
		Duel.HintSelection(g)
		-- 将选择的卡以效果原因破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 怪兽效果③的发动条件：这张卡被破坏前位于怪兽区域且当时是表侧表示。
function c24070330.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 放置灵摆区域前的目标检测：确认自己的灵摆区域有空位。
function c24070330.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的灵摆区域0号位或1号位是否存在空位。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 放置处理：若这张卡仍与效果相关，则将其在自己的灵摆区域表侧表示放置。
function c24070330.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡移动到自己的灵摆区域，表侧表示放置，并立即适用其效果。
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
