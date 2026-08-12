--アマゾネスの秘湯
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「亚马逊」怪兽加入手卡或选1只「亚马逊」灵摆怪兽在自己的灵摆区域放置。
-- ②：自己场上有「亚马逊」怪兽卡存在，自己受到战斗伤害时才能发动。自己基本分回复受到的伤害的数值。
function c62480168.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「亚马逊」怪兽加入手卡或选1只「亚马逊」灵摆怪兽在自己的灵摆区域放置。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c62480168.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上有「亚马逊」怪兽卡存在，自己受到战斗伤害时才能发动。自己基本分回复受到的伤害的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,62480168)
	e2:SetCondition(c62480168.rccon)
	e2:SetTarget(c62480168.rctg)
	e2:SetOperation(c62480168.rcop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中可以加入手卡的「亚马逊」怪兽，或者可以放置到灵摆区域的「亚马逊」灵摆怪兽
function c62480168.filter(c,tp,pcon)
	return c:IsSetCard(0x4) and c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or c:IsType(TYPE_PENDULUM) and pcon)
end
-- 这张卡发动时的效果处理：可以从卡组选择1只「亚马逊」怪兽加入手卡，或将1只「亚马逊」灵摆怪兽放置到自己的灵摆区域
function c62480168.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的灵摆区域是否有空位
	local pcon=Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)
	-- 获取卡组中所有符合条件的「亚马逊」怪兽
	local g=Duel.GetMatchingGroup(c62480168.filter,tp,LOCATION_DECK,0,nil,tp,pcon)
	-- 如果卡组中存在符合条件的卡，询问玩家是否进行检索或放置灵摆卡的操作
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(62480168,0)) then  --"是否从卡组选卡？"
		-- 给玩家发送选择卡片的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		local sc=g:Select(tp,1,1,nil):GetFirst()
		if sc then
			local b1=sc:IsAbleToHand()
			local b2=sc:IsType(TYPE_PENDULUM) and pcon
			local s=0
			if b1 and not b2 then
				-- 当选中的卡只能加入手卡时，强制选择“加入手卡”选项
				s=Duel.SelectOption(tp,aux.Stringid(62480168,1))  --"加入手卡"
			end
			if not b1 and b2 then
				-- 当选中的卡只能放置到灵摆区域时，强制选择“在灵摆区域放置”选项
				s=Duel.SelectOption(tp,aux.Stringid(62480168,2))+1  --"在灵摆区域放置"
			end
			if b1 and b2 then
				-- 当选中的卡既能加入手卡也能放置到灵摆区域时，让玩家选择其中一项操作
				s=Duel.SelectOption(tp,aux.Stringid(62480168,1),aux.Stringid(62480168,2))  --"加入手卡/在灵摆区域放置"
			end
			if s==0 then
				-- 将选中的卡加入手卡
				Duel.SendtoHand(sc,nil,REASON_EFFECT)
				-- 给对方玩家确认加入手卡的卡片
				Duel.ConfirmCards(1-tp,sc)
			end
			if s==1 then
				-- 将选中的灵摆怪兽在自己的灵摆区域表侧表示放置
				Duel.MoveToField(sc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			end
		end
	end
end
-- 过滤自己场上表侧表示的原本是怪兽的「亚马逊」卡片
function c62480168.cfilter(c)
	return c:IsSetCard(0x4) and c:IsFaceup() and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 效果②的发动条件：自己受到战斗伤害，且自己场上有「亚马逊」怪兽卡存在
function c62480168.rccon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查受到伤害的玩家是否为自己，且自己场上是否存在表侧表示的「亚马逊」怪兽卡
	return ep==tp and Duel.IsExistingMatchingCard(c62480168.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果②的发动准备：设置回复基本分的操作信息
function c62480168.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置在效果处理时使自己回复等同于受到的战斗伤害数值的基本分的操作信息
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
end
-- 效果②的效果处理：自己回复受到的战斗伤害数值的基本分
function c62480168.rcop(e,tp,eg,ep,ev,re,r,rp)
	-- 使自己回复等同于受到的战斗伤害数值的基本分
	Duel.Recover(tp,ev,REASON_EFFECT)
end
