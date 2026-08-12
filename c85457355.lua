--変容王 ヘル・ゲル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。这张卡的等级变成和那只怪兽相同，自己回复那只怪兽的等级×200基本分。这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
-- ②：自己主要阶段才能发动。从手卡把持有比这张卡低的等级的1只恶魔族怪兽特殊召唤。
function c85457355.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。这张卡的等级变成和那只怪兽相同，自己回复那只怪兽的等级×200基本分。这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85457355,0))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,85457355)
	e1:SetTarget(c85457355.lvtg)
	e1:SetOperation(c85457355.lvop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。从手卡把持有比这张卡低的等级的1只恶魔族怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(85457355,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,85457356)
	e3:SetTarget(c85457355.sptg)
	e3:SetOperation(c85457355.spop)
	c:RegisterEffect(e3)
end
-- 过滤场上表侧表示、等级在1以上且与自身等级不同的怪兽
function c85457355.lvfilter(c,lv)
	return c:IsFaceup() and c:IsLevelAbove(1) and not c:IsLevel(lv)
end
-- 效果①的发动准备与条件判定
function c85457355.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c85457355.lvfilter(chkc) and chkc~=e:GetHandler() end
	local lv=e:GetHandler():GetLevel()
	-- 检查场上是否存在除自身以外、等级在1以上且与自身等级不同的表侧表示怪兽，并确认自身等级在1以上且在场上
	if chk==0 then return Duel.IsExistingTarget(c85457355.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler(),lv)
		and e:GetHandler():IsLevelAbove(1) and e:GetHandler():IsRelateToEffect(e) end
	-- 提示玩家选择作为效果对象的一只怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上一只除自身以外、等级在1以上且与自身等级不同的表侧表示怪兽作为对象
	local g=Duel.SelectTarget(tp,c85457355.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler(),lv)
	local rec=g:GetFirst():GetLevel()*200
	-- 设置效果处理信息，准备回复等同于目标怪兽等级×200的基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- 效果①的处理：改变自身等级，回复基本分，并适用“直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤”的限制
function c85457355.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local lv=tc:GetLevel()
		-- 这张卡的等级变成和那只怪兽相同
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		-- 使玩家回复目标怪兽等级×200的基本分
		Duel.Recover(tp,lv*200,REASON_EFFECT)
	end
	-- 这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。②：自己主要阶段才能发动。从手卡把持有比这张卡低的等级的1只恶魔族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c85457355.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册并适用直到回合结束时自己不能从额外卡组特殊召唤同调怪兽以外怪兽的玩家限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制玩家不能从额外卡组特殊召唤同调怪兽以外的怪兽
function c85457355.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤手卡中等级比自身低且可以特殊召唤的恶魔族怪兽
function c85457355.spfilter(c,e,tp,lv)
	return c:IsRace(RACE_FIEND) and c:IsLevelBelow(lv-1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与条件判定
function c85457355.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local lv=e:GetHandler():GetLevel()
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自身等级在2以上，且手卡中存在等级比自身低、可特殊召唤的恶魔族怪兽
		and e:GetHandler():IsLevelAbove(2) and Duel.IsExistingMatchingCard(c85457355.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,lv) end
	-- 设置效果处理信息，准备从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的处理：从手卡特殊召唤1只等级比自身低的恶魔族怪兽
function c85457355.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空位，若无则直接结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if c:IsFaceup() and c:IsLevelAbove(2) then
		local lv=c:GetLevel()
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡选择1只等级比自身低的恶魔族怪兽
		local g=Duel.SelectMatchingCard(tp,c85457355.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,lv)
		if g:GetCount()>0 then
			-- 将选择的怪兽在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
