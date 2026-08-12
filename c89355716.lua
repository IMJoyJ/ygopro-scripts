--晴れの天気模様
-- 效果：
-- ①：「晴之天气模样」在自己场上只能有1张表侧表示存在。
-- ②：和这张卡相同纵列的自己的主要怪兽区域以及那些两邻的自己的主要怪兽区域存在的「天气」效果怪兽得到以下效果。
-- ●把这张卡除外，以自己场上1只怪兽为对象才能发动。那只自己怪兽解放，从自己的手卡·墓地选和那只怪兽卡名不同的1只「天气」怪兽特殊召唤。这个效果在对方回合也能发动。
function c89355716.initial_effect(c)
	c:SetUniqueOnField(1,0,89355716)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ●把这张卡除外，以自己场上1只怪兽为对象才能发动。那只自己怪兽解放，从自己的手卡·墓地选和那只怪兽卡名不同的1只「天气」怪兽特殊召唤。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(89355716,0))  --"「天气」怪兽特殊召唤（晴之天气模样）"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	-- 把这张卡除外作为发动成本
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c89355716.sptg)
	e2:SetOperation(c89355716.spop)
	-- ②：和这张卡相同纵列的自己的主要怪兽区域以及那些两邻的自己的主要怪兽区域存在的「天气」效果怪兽得到以下效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c89355716.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 过滤条件：相同纵列及相邻纵列的自己主要怪兽区域的「天气」效果怪兽
function c89355716.eftg(e,c)
	local seq=c:GetSequence()
	return c:IsType(TYPE_EFFECT) and c:IsSetCard(0x109)
		and seq<5 and math.abs(e:GetHandler():GetSequence()-seq)<=1
end
-- 过滤条件：自己场上可以被效果解放，且手牌或墓地存在与其卡名不同的「天气」怪兽可以特殊召唤的怪兽
function c89355716.spcfilter(c,e,tp,ft)
	return c:IsReleasableByEffect() and (ft>0 or c:GetSequence()<5)
		-- 检查手牌或墓地是否存在与该怪兽卡名不同的、可特殊召唤的「天气」怪兽
		and Duel.IsExistingMatchingCard(c89355716.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,c:GetCode())
end
-- 过滤条件：手牌或墓地中与被解放怪兽卡名不同、且可以特殊召唤的「天气」怪兽
function c89355716.spfilter(c,e,tp,code)
	return c:IsSetCard(0x109) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果2（授予效果）的发动准备与目标选择（Target阶段）
function c89355716.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场上可用怪兽区域的数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c89355716.spcfilter(chkc,e,tp,ft) end
	-- 在chk为0（检查发动可行性）时，判断自己场上是否存在符合解放条件的怪兽（排除自身）
	if chk==0 then return Duel.IsExistingTarget(c89355716.spcfilter,tp,LOCATION_MZONE,0,1,e:GetHandler(),e,tp,ft) end
	-- 向对方玩家提示发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择自己场上1只怪兽作为效果对象
	Duel.SelectTarget(tp,c89355716.spcfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),e,tp,ft)
	-- 设置效果处理信息：从手牌或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果2（授予效果）的效果处理（Resolution阶段）
function c89355716.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 如果对象怪兽仍由自己控制、与效果相关联，则将其因效果解放
	if tc:IsControler(tp) and tc:IsRelateToEffect(e) and Duel.Release(tc,REASON_EFFECT)>0
		-- 并且此时自己场上仍有空余的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌或墓地选择1只与被解放怪兽卡名不同的「天气」怪兽（受王家之谷影响）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c89355716.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,tc:GetCode())
		if g:GetCount()>0 then
			-- 将选择的「天气」怪兽以表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
