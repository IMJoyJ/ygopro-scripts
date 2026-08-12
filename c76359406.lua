--水晶機巧－アメトリクス
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡同调召唤成功的场合才能发动。对方场上的特殊召唤的表侧表示怪兽全部变成守备表示。
-- ②：同调召唤的这张卡被战斗·效果破坏的场合，以同调怪兽以外的自己墓地1只「水晶机巧」怪兽为对象才能发动。那只怪兽特殊召唤。
function c76359406.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功的场合才能发动。对方场上的特殊召唤的表侧表示怪兽全部变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76359406,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c76359406.poscon)
	e1:SetTarget(c76359406.postg)
	e1:SetOperation(c76359406.posop)
	c:RegisterEffect(e1)
	-- ②：同调召唤的这张卡被战斗·效果破坏的场合，以同调怪兽以外的自己墓地1只「水晶机巧」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(76359406,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c76359406.spcon)
	e2:SetTarget(c76359406.sptg)
	e2:SetOperation(c76359406.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：这张卡同调召唤成功
function c76359406.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤条件：对方场上表侧攻击表示、特殊召唤且可以改变表示形式的怪兽
function c76359406.posfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsCanChangePosition()
end
-- 效果①的发动阶段：检查是否存在符合条件的怪兽，并设置改变表示形式的操作信息
function c76359406.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c76359406.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有符合条件的怪兽
	local g=Duel.GetMatchingGroup(c76359406.posfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：改变这些怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果①的处理阶段：将对方场上特殊召唤的表侧表示怪兽全部变成守备表示
function c76359406.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上当前所有符合条件的怪兽
	local g=Duel.GetMatchingGroup(c76359406.posfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将这些怪兽全部变成表侧守备表示
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	end
end
-- 效果②的发动条件：同调召唤的这张卡被战斗或效果破坏
function c76359406.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 过滤条件：自己墓地中同调怪兽以外的「水晶机巧」怪兽，且可以特殊召唤
function c76359406.spfilter(c,e,tp)
	return c:IsSetCard(0xea) and not c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动阶段：检查怪兽区域空位及墓地中是否存在符合条件的怪兽，并选择1只作为对象
function c76359406.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c76359406.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地中存在至少1只符合条件的「水晶机巧」怪兽
		and Duel.IsExistingTarget(c76359406.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地中1只符合条件的「水晶机巧」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c76359406.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的处理阶段：将选中的墓地怪兽特殊召唤
function c76359406.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
