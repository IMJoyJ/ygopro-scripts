--オルターガイスト・ペリネトレータ
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡可以直接攻击。
-- ②：这张卡给与对方战斗伤害时才能发动。自己抽1张。
-- ③：这张卡从场上送去墓地的场合才能发动。从自己的手卡·卡组·场上（表侧表示）把「幻变骚灵·渗透佩里」以外的1张「幻变骚灵」卡送去墓地。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含直接攻击、给与战斗伤害时抽卡、从场上送去墓地时将「幻变骚灵」卡送去墓地的效果
function s.initial_effect(c)
	-- ①：这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- ②：这张卡给与对方战斗伤害时才能发动。自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	-- ③：这张卡从场上送去墓地的场合才能发动。从自己的手卡·卡组·场上（表侧表示）把「幻变骚灵·渗透佩里」以外的1张「幻变骚灵」卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.tgcon)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
-- 检查受到战斗伤害的玩家是否为对方，作为效果②的发动条件
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果②的发动准备与合法性检测函数，设置抽卡玩家、抽卡数量及操作信息
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以效果抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数（抽卡数量）设置为1
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②的效果处理函数，执行抽卡操作
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和目标参数（抽卡数量）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 检查这张卡此前是否在场上，作为效果③的发动条件
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：属于「幻变骚灵」且卡名不是「幻变骚灵·渗透佩里」的卡，如果是场上的卡则必须是表侧表示，且能送去墓地
function s.tgfilter(c)
	return c:IsSetCard(0x103) and not c:IsCode(id) and c:IsFaceupEx() and c:IsAbleToGrave()
end
-- 效果③的发动准备与合法性检测函数，检查是否存在可送去墓地的卡并设置操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的手卡、卡组、场上是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	-- 设置当前连锁的操作信息为：从自己的手卡、卡组、场上将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD)
end
-- 效果③的效果处理函数，让玩家选择1张满足条件的卡送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己的手卡、卡组、场上选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
