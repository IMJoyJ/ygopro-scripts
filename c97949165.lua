--LL－ターコイズ・ワーブラー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡从手卡的特殊召唤成功的场合才能发动。从自己的手卡·墓地选1只「抒情歌鸲」怪兽特殊召唤。
function c97949165.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c97949165.hspcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡从手卡的特殊召唤成功的场合才能发动。从自己的手卡·墓地选1只「抒情歌鸲」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97949165,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCountLimit(1,97949165)
	e2:SetCondition(c97949165.spcon)
	e2:SetTarget(c97949165.sptg)
	e2:SetOperation(c97949165.spop)
	c:RegisterEffect(e2)
end
-- 自身手卡特殊召唤效果的条件判断函数
function c97949165.hspcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否存在怪兽（数量为0）
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 过滤手卡·墓地中满足特殊召唤条件的「抒情歌鸲」怪兽
function c97949165.spfilter(c,e,tp)
	return c:IsSetCard(0xf7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查这张卡是否是从手卡特殊召唤成功
function c97949165.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 效果②的发动准备与目标确认函数
function c97949165.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动检测时，检查自己的手卡或墓地是否存在至少1只可以特殊召唤的「抒情歌鸲」怪兽
		and Duel.IsExistingMatchingCard(c97949165.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果②的效果处理（特殊召唤）函数
function c97949165.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上没有可用的怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 在客户端显示“请选择要特殊召唤的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或墓地选择1只满足条件的「抒情歌鸲」怪兽（适用王家长眠之谷的过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c97949165.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
