--ウィザード＠イグニスター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从额外卡组特殊召唤的电子界族怪兽在自己场上存在的场合，以自己墓地1只电子界族·暗属性怪兽为对象才能发动。那只怪兽和手卡的这张卡守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。
-- ②：把场上·墓地的这张卡除外，以对方场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
local s,id,o=GetID()
-- 创建两个效果，分别对应①②效果，①效果在手牌发动，②效果在场上或墓地发动
function s.initial_effect(c)
	-- ①：从额外卡组特殊召唤的电子界族怪兽在自己场上存在的场合，以自己墓地1只电子界族·暗属性怪兽为对象才能发动。那只怪兽和手卡的这张卡守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：把场上·墓地的这张卡除外，以对方场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"改变表示形式"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 效果②的发动需要将此卡从场上或墓地除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上存在从额外卡组召唤的电子界族怪兽
function s.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsFaceup()
		and c:IsRace(RACE_CYBERSE)
end
-- 效果①的发动条件：场上存在从额外卡组召唤的电子界族怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果①的发动条件：场上存在从额外卡组召唤的电子界族怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：墓地的电子界族暗属性怪兽可以被特殊召唤
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动时选择目标：从自己墓地选择一只电子界族暗属性怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 效果①的发动条件：自己场上存在至少2个空场
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 效果①的发动条件：自己墓地存在一只电子界族暗属性怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择一只电子界族暗属性怪兽作为特殊召唤的目标
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	g:AddCard(c)
	-- 设置效果处理信息，表示将特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 效果①的处理：将目标怪兽和手卡的此卡守备表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且未受王家长眠之谷影响
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 then
		local g=Group.FromCards(c,tc)
		-- 执行特殊召唤操作
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 效果①发动后，直到回合结束时自己不能特殊召唤非电子界族怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.splimit)
	-- 注册效果①的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的目标：非电子界族怪兽不能特殊召唤
function s.splimit(e,c)
	return not c:IsRace(RACE_CYBERSE)
end
-- 过滤条件：目标怪兽可以改变表示形式
function s.posfilter(c)
	return c:IsCanChangePosition()
end
-- 效果②的发动时选择目标：选择对方场上一只可以改变表示形式的怪兽
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.posfilter(chkc) and chkc:IsControler(1-tp) end
	-- 效果②的发动条件：对方场上存在一只可以改变表示形式的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择一只对方场上的怪兽作为改变表示形式的目标
	local g=Duel.SelectTarget(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示将改变目标怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果②的处理：改变目标怪兽的表示形式
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽变为表侧守备表示或表侧攻击表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
