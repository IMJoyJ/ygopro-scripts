--守護獣セルケト
-- 效果：
-- 这张卡不能通常召唤。「守护兽 塞勒凯特」1回合1次在自己场上有「王家的神殿」存在的状态，从手卡·卡组把1只10星以上的怪兽除外的场合可以特殊召唤。
-- ①：1回合1次，自己主要阶段才能发动。把1张「王家的神殿」或者有那个卡名记述的魔法卡从卡组加入手卡。
-- ②：这张卡和对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽破坏，这张卡的攻击力上升破坏的怪兽的原本攻击力一半数值。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果：特殊召唤、检索、战斗破坏与攻击力上升
function s.initial_effect(c)
	-- 记录该卡效果文本上记载着「王家的神殿」（卡号29762407）
	aux.AddCodeList(c,29762407)
	c:EnableReviveLimit()
	-- ①：1回合1次在自己场上有「王家的神殿」存在的状态，从手卡·卡组把1只10星以上的怪兽除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.sprcon)
	e1:SetTarget(s.sprtg)
	e1:SetOperation(s.sprop)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己主要阶段才能发动。把1张「王家的神殿」或者有那个卡名记述的魔法卡从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：这张卡和对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽破坏，这张卡的攻击力上升破坏的怪兽的原本攻击力一半数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断手卡或卡组中是否存在满足条件的怪兽（可除外、10星以上）
function s.cfilter(c,tp)
	return c:IsAbleToRemoveAsCost() and c:IsAbleToRemove(tp,POS_FACEUP,REASON_SPSUMMON) and c:IsLevelAbove(10)
end
-- 特殊召唤条件函数，判断是否满足特殊召唤的条件（有空场、有符合条件的怪兽、场上存在「王家的神殿」）
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断当前玩家场上是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断当前玩家手卡或卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,c,tp)
		-- 判断当前玩家场上是否存在「王家的神殿」
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_ONFIELD,0,1,nil,29762407)
end
-- 特殊召唤目标选择函数，从满足条件的怪兽中选择一张进行除外
function s.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_DECK,0,c,tp)
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤操作函数，将选中的怪兽除外
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将目标怪兽以除外形式移除
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 检索过滤函数，判断是否为「王家的神殿」或记载其名称的魔法卡
function s.thfilter(c)
	-- 判断是否为「王家的神殿」或记载其名称的魔法卡且可加入手牌
	return (c:IsCode(29762407) or aux.IsCodeListed(c,29762407) and c:IsType(TYPE_SPELL)) and c:IsAbleToHand()
end
-- 检索效果目标函数，判断是否可以发动检索效果
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否卡组中存在满足条件的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果操作函数，选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 战斗破坏效果目标函数，判断是否可以发动破坏效果
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	if chk==0 then return tc and tc:IsControler(1-tp) end
	e:SetLabelObject(tc)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 战斗破坏效果操作函数，破坏对方怪兽并提升自身攻击力
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	-- 判断对方怪兽是否参与战斗且可被破坏
	if tc and tc:IsRelateToBattle() and tc:IsType(TYPE_MONSTER) and tc:IsControler(1-tp) and Duel.Destroy(tc,REASON_EFFECT)~=0
		and c:IsFaceup() and c:IsRelateToEffect(e) then
		local atk=tc:GetTextAttack()
		if atk<0 then atk=0 end
		if atk>0 then
			-- 提升自身攻击力的效果，数值为被破坏怪兽攻击力的一半（向上取整）
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(math.ceil(atk/2))
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
