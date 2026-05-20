--バッド・エンド・クイーン・ドラゴン
-- 效果：
-- 这张卡不能通常召唤。自己场上有永续魔法卡3张以上表侧表示存在的场合可以特殊召唤。这张卡的攻击给与对方基本分战斗伤害时，对方选择1张手卡送去墓地，自己从卡组抽1张卡。此外，这张卡从场上送去墓地的场合，自己的准备阶段时，可以把自己场上表侧表示存在的1张永续魔法卡送去墓地，这张卡从墓地特殊召唤。
function c80513550.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。自己场上有永续魔法卡3张以上表侧表示存在的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c80513550.hspcon)
	c:RegisterEffect(e1)
	-- 这张卡的攻击给与对方基本分战斗伤害时，对方选择1张手卡送去墓地，自己从卡组抽1张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80513550,0))  --"抽卡"
	e2:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCondition(c80513550.hdcon)
	e2:SetTarget(c80513550.hdtg)
	e2:SetOperation(c80513550.hdop)
	c:RegisterEffect(e2)
	-- 此外，这张卡从场上送去墓地的场合，自己的准备阶段时，可以把自己场上表侧表示存在的1张永续魔法卡送去墓地，这张卡从墓地特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(80513550,1))  --"特殊召唤"
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1)
	e3:SetCondition(c80513550.spcon)
	e3:SetCost(c80513550.spcost)
	e3:SetTarget(c80513550.sptg)
	e3:SetOperation(c80513550.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：表侧表示的永续魔法卡
function c80513550.hspfilter(c)
	return c:IsFaceup() and c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS
end
-- 自身特殊召唤规则的条件判定
function c80513550.hspcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少3张表侧表示的永续魔法卡
		and Duel.IsExistingMatchingCard(c80513550.hspfilter,c:GetControler(),LOCATION_SZONE,0,3,nil)
end
-- 战斗伤害效果的发动条件判定
function c80513550.hdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定是否为这张卡的攻击给与对方玩家战斗伤害
	return ep~=tp and e:GetHandler()==Duel.GetAttacker()
end
-- 战斗伤害效果的发动准备与效果分类声明
function c80513550.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：对方丢弃1张手卡
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
	-- 设置操作信息：自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 战斗伤害效果的实际处理
function c80513550.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方手卡是否不为0且自己是否可以抽卡
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)~=0 and Duel.IsPlayerCanDraw(tp,1) then
		-- 让对方选择1张手卡送去墓地
		Duel.DiscardHand(1-tp,nil,1,1,REASON_EFFECT)
		-- 自己从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 墓地特殊召唤效果的发动条件判定
function c80513550.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为自己的回合，且这张卡之前是从场上送去墓地
	return Duel.GetTurnPlayer()==tp and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：表侧表示且可以作为cost送去墓地的永续魔法卡
function c80513550.cfilter(c)
	return c:IsFaceup() and c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS and c:IsAbleToGraveAsCost()
end
-- 墓地特殊召唤效果的cost处理
function c80513550.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1张可以送去墓地的表侧表示永续魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c80513550.cfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1张表侧表示的永续魔法卡
	local g=Duel.SelectMatchingCard(tp,c80513550.cfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 将选择的卡作为cost送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 墓地特殊召唤效果的发动准备与效果分类声明
function c80513550.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 墓地特殊召唤效果的实际处理
function c80513550.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
