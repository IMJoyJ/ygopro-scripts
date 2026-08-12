--ダイナレスラー・ラアムブラキオ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己的「恐龙摔跤手」怪兽给与对方战斗伤害时才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：只要这张卡在怪兽区域存在，自己场上的其他的「恐龙摔跤手」怪兽不会成为对方的效果的对象。
function c61764082.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己的「恐龙摔跤手」怪兽给与对方战斗伤害时才能发动。这张卡从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61764082,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,61764082)
	e1:SetCondition(c61764082.spcon)
	e1:SetTarget(c61764082.sptg)
	e1:SetOperation(c61764082.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己场上的其他的「恐龙摔跤手」怪兽不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c61764082.tgtg)
	-- 设置不能成为对方卡片效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end
-- 发动条件：检查造成战斗伤害的怪兽是否为自己控制的「恐龙摔跤手」怪兽，且受到伤害的是对方
function c61764082.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return ep~=tp and tc:IsControler(tp) and tc:IsSetCard(0x11a)
end
-- 发动准备：检查怪兽区域是否有空位，以及这张卡是否能特殊召唤，并设置特殊召唤的操作信息
function c61764082.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置特殊召唤的操作信息，将1张自身卡片作为特殊召唤的对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍存在于手卡中，则将其表侧守备表示特殊召唤
function c61764082.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧守备表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 过滤出自己场上除这张卡以外的其他「恐龙摔跤手」怪兽
function c61764082.tgtg(e,c)
	return c~=e:GetHandler() and c:IsSetCard(0x11a)
end
