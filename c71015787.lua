--サイレント・ウォビー
-- 效果：
-- 自己的主要阶段时才能发动。这张卡从手卡往对方场上特殊召唤。这个效果特殊召唤成功时，这张卡的控制者从卡组抽1张卡，从这张卡的控制者来看的对方玩家回复2000基本分。「寂静须鲨」的这个效果1回合只能使用1次。此外，只要这张卡在场上表侧表示存在，这张卡的控制者的手卡限制数量变成3张。
function c71015787.initial_effect(c)
	-- 自己的主要阶段时才能发动。这张卡从手卡往对方场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71015787,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetTarget(c71015787.sptg)
	e1:SetOperation(c71015787.spop)
	c:RegisterEffect(e1)
	-- 这个效果特殊召唤成功时，这张卡的控制者从卡组抽1张卡，从这张卡的控制者来看的对方玩家回复2000基本分。「寂静须鲨」的这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(71015787,1))  --"抽卡回复"
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,71015787)
	e2:SetCondition(c71015787.effcon)
	e2:SetTarget(c71015787.efftg)
	e2:SetOperation(c71015787.effop)
	c:RegisterEffect(e2)
	-- 此外，只要这张卡在场上表侧表示存在，这张卡的控制者的手卡限制数量变成3张。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_HAND_LIMIT)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,0)
	e3:SetValue(3)
	c:RegisterEffect(e3)
end
-- 特殊召唤效果的发动条件与合法性检测函数
function c71015787.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp) end
	-- 设置效果处理的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的执行函数
function c71015787.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以自身效果特殊召唤到对方场上
		Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,1-tp,false,false,POS_FACEUP)
	end
end
-- 检查此卡是否是通过自身效果特殊召唤成功
function c71015787.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 抽卡与回复效果的发动准备与操作信息设置函数
function c71015787.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理的操作信息为抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	-- 设置效果处理的操作信息为回复生命值
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,2000)
end
-- 抽卡与回复效果的执行函数
function c71015787.effop(e,tp,eg,ep,ev,re,r,rp)
	-- 让当前控制者抽1张卡
	Duel.Draw(tp,1,REASON_EFFECT)
	-- 让当前控制者的对手回复2000基本分
	Duel.Recover(1-tp,2000,REASON_EFFECT)
end
