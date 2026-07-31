--浄化と腐敗のアルス＝マグナ
local s,id,o=GetID()
-- 初始化卡片效果：注册①手牌除外检索「烙印」魔陷及战破耐性、②除外状态诱发特召、③/④场上起动/诱发即时除外魔陷效果
function s.initial_effect(c)
	-- ①：把手卡的这张卡表侧表示除外才能发动。从卡组把1张「烙印」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的状态，超量·连接怪兽特殊召唤的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：以自己场上的「教导」连接怪兽数量的对方场上的魔法·陷阱卡为对象才能发动。那些卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.rmcon1)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCondition(s.rmcon2)
	c:RegisterEffect(e4)
end
-- ①效果发动Cost：除外手牌的自身
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	-- 将手牌的自身表侧表示除外
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end
-- 卡组检索过滤条件：可以加入手牌的「烙印」魔法·陷阱卡
function s.thfilter(c)
	return c:IsSetCard(0x1e6) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果发动准备：设置从卡组检索卡片的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 发动条件检查：卡组是否存在可以加入手牌的「烙印」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组把1张「烙印」魔陷加入手牌，并赋予己方「教导」Link怪兽战斗破坏耐性
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足条件的「烙印」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
	-- 直到下一个回合结束时，自己场上的「教导」连接怪兽不会被战斗破坏（最多3次）。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetValue(s.indct)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 为己方玩家注册全场「教导」Link怪兽战斗破坏耐性效果
	Duel.RegisterEffect(e1,tp)
	-- 注册玩家提示状态信息（显示战斗破坏耐性效果适用中）
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(id)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END,2)
	-- 为己方玩家注册状态提示信息
	Duel.RegisterEffect(e2,tp)
end
-- 耐性目标过滤条件：自己场上的「教导」Link怪兽
function s.atktg(e,c)
	return c:IsSetCard(0x1ce) and c:IsType(TYPE_LINK)
end
-- 计算破坏耐性次数：战斗破坏提供最多3次耐性
function s.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)~=0 then
		return 3
	else return 0 end
end
-- ②效果触发条件过滤：表侧表示的超量怪兽或连接怪兽
function s.cfilter(c,tp,se)
	return c:IsFaceup() and c:IsType(TYPE_XYZ+TYPE_LINK)
end
-- ②效果发动条件：场上有表侧表示超量·连接怪兽特殊召唤成功
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,e:GetHandler())
end
-- ②效果发动准备：设置特殊召唤自身的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：主要怪兽区域有空位且自身可特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：特殊召唤自身1张
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：将除外区的此卡表侧表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将此卡表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 二速触发条件过滤：自己场上的表侧表示「教导」Link怪兽
function s.confilter(c)
	return c:IsSetCard(0x1ce) and c:IsType(TYPE_LINK) and c:IsFaceup()
end
-- 一速起动效果发动条件：不满足二速发动的条件
function s.rmcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否不能作为二速诱发即时效果发动
	return not aux.IsCanBeQuickEffect(e:GetHandler(),tp,37279096)
end
-- 二速诱发即时效果发动条件：满足二速条件或自己场上有「教导」Link怪兽
function s.rmcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否满足二速发动的特定效果赋予
	return aux.IsCanBeQuickEffect(e:GetHandler(),tp,37279096)
		-- 检查自己场上是否存在表侧表示的「教导」Link怪兽
		and Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 除外目标过滤条件：可以除外的魔法·陷阱卡
function s.rmfilter(c)
	return c:IsAbleToRemove() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ③效果发动准备：选择对方场上的魔法·陷阱卡为对象
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 计算自己场上表侧表示「教导」Link怪兽的数量
	local ct=Duel.GetMatchingGroupCount(s.confilter,tp,LOCATION_MZONE,0,nil)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.rmfilter(chkc) end
	-- 发动条件检查：拥有「教导」Link怪兽且场上有可除外的魔陷
	if chk==0 then return ct>0 and Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择最多等同于「教导」Link怪兽数量的场上魔陷作为对象
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	-- 设置连锁操作信息：除外选中的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ③效果处理：将选中的目标魔法·陷阱卡表侧表示除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取依然在场上的效果对象卡片
	local tg=Duel.GetTargetsRelateToChain():Filter(Card.IsOnField,nil)
	if tg:GetCount()>0 then
		-- 将对象卡片表侧表示除外
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end
