--魔轟神ガミュジン
-- 效果：
-- 「魔轰神」调整＋调整以外的怪兽1只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从手卡·卡组把1只「魔轰神」怪兽特殊召唤。
-- ②：只要这张卡在怪兽区域存在，对方不能把自己场上的其他的「魔轰神」同调怪兽作为效果的对象。
-- ③：这张卡被送去墓地的场合才能发动。自己抽出自己场上的「魔轰神」同调怪兽的数量。那之后，选自己1张手卡丢弃。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 设置同调召唤手续：以「魔轰神」怪兽为调整，调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x35),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。从手卡·卡组把1只「魔轰神」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，对方不能把自己场上的其他的「魔轰神」同调怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.tglimit)
	-- 设置不能成为对方卡片效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合才能发动。自己抽出自己场上的「魔轰神」同调怪兽的数量。那之后，选自己1张手卡丢弃。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DRAW|CATEGORY_HANDES_SELF)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：这张卡是同调召唤成功的
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果①的过滤条件：手卡·卡组中可以特殊召唤的「魔轰神」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x35) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（检查怪兽区域是否有空位、手卡或卡组中是否有可特召的「魔轰神」怪兽，并设置特殊召唤的操作信息）
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身场上是否有空余的怪兽区域，以及手卡或卡组中是否存在至少1只满足过滤条件的「魔轰神」怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁的操作信息，表示此效果包含从手卡或卡组特殊召唤1只怪兽的处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果①的效果处理：从手卡或卡组选择1只「魔轰神」怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身场上是否有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 过滤并让玩家从手卡或卡组选择1只满足条件的「魔轰神」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的过滤条件：自身以外的、自己场上表侧表示的「魔轰神」同调怪兽
function s.tglimit(e,c)
	return c~=e:GetHandler() and c:IsSetCard(0x35) and c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
-- 效果③的过滤条件：自己场上表侧表示的「魔轰神」同调怪兽
function s.drfilter(c)
	return c:IsSetCard(0x35) and c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
-- 效果③的发动准备（计算自己场上「魔轰神」同调怪兽的数量，检查是否可以抽卡，并设置抽卡和丢弃手卡的操作信息）
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算自己场上表侧表示的「魔轰神」同调怪兽的数量
	local ct=Duel.GetMatchingGroupCount(s.drfilter,tp,LOCATION_MZONE,0,nil)
	-- 检查场上是否存在「魔轰神」同调怪兽，且玩家是否可以抽出对应数量的卡
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	-- 设置当前连锁的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,ct,tp,1)
end
-- 效果③的效果处理：抽出自己场上「魔轰神」同调怪兽数量的卡，那之后选自己1张手卡丢弃
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新计算当前自己场上表侧表示的「魔轰神」同调怪兽的数量
	local ct=Duel.GetMatchingGroupCount(s.drfilter,tp,LOCATION_MZONE,0,nil)
	if ct==0 then return end
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 让目标玩家因效果抽出对应数量的卡，若成功抽卡则继续处理
	if Duel.Draw(p,ct,REASON_EFFECT)>0 then
		-- 中断当前效果，使之后的丢弃手卡处理与抽卡不视为同时处理
		Duel.BreakEffect()
		-- 让玩家选择自己1张手卡丢弃
		Duel.DiscardHand(p,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
