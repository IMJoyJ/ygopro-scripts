--サイバネット・ストーム
-- 效果：
-- ①：场上的连接状态的怪兽的攻击力·守备力上升500。
-- ②：只要这张卡在场地区域存在，连接怪兽的连接召唤不会被无效化。
-- ③：自己受到2000以上的战斗·效果伤害的场合才能发动。只把自己的额外卡组的里侧表示的卡洗切，那张最上面的卡翻开。翻开的卡是电子界族连接怪兽的场合，那只怪兽特殊召唤。不是的场合回到原状。
function c42461852.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的连接状态的怪兽的攻击力·守备力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 筛选场上连接状态的怪兽作为效果对象
	e2:SetTarget(aux.TargetBoolFunction(Card.IsLinkState))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在场地区域存在，连接怪兽的连接召唤不会被无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	-- 筛选连接怪兽作为效果对象
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSummonType,SUMMON_TYPE_LINK))
	c:RegisterEffect(e4)
	-- ③：自己受到2000以上的战斗·效果伤害的场合才能发动。只把自己的额外卡组的里侧表示的卡洗切，那张最上面的卡翻开。翻开的卡是电子界族连接怪兽的场合，那只怪兽特殊召唤。不是的场合回到原状。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(42461852,0))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DAMAGE)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_CAL)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCondition(c42461852.spcon)
	e5:SetTarget(c42461852.sptg)
	e5:SetOperation(c42461852.spop)
	c:RegisterEffect(e5)
end
-- 判断是否为己方受到2000以上伤害
function c42461852.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and ev>=2000
end
-- 检查是否满足发动条件：额外卡组有里侧表示的卡、己方可以特殊召唤、场上存在可特殊召唤的空位
function c42461852.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在里侧表示的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_EXTRA,0,1,nil)
		-- 检查己方是否可以特殊召唤
		and Duel.IsPlayerCanSpecialSummon(tp)
		-- 检查己方额外卡组是否有足够的特殊召唤空位
		and Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_LINK)>0 end
	-- 设置连锁操作信息：准备特殊召唤一张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 再次检查发动条件：己方可以特殊召唤、额外卡组存在里侧表示的卡
function c42461852.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方是否可以特殊召唤
	if not Duel.IsPlayerCanSpecialSummon(tp)
		-- 检查额外卡组是否存在里侧表示的卡
		or Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_EXTRA,0,nil)==0 then return end
	-- 将己方额外卡组洗切
	Duel.ShuffleExtra(tp)
	-- 翻开己方额外卡组最上方的1张卡
	Duel.ConfirmExtratop(tp,1)
	-- 获取翻开的卡
	local tc=Duel.GetExtraTopGroup(tp,1):GetFirst()
	if tc:IsType(TYPE_LINK) and tc:IsRace(RACE_CYBERSE) then
		-- 如果翻开的卡是电子界族连接怪兽，则特殊召唤该怪兽
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
