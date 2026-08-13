--ワーム・コール
-- 效果：
-- 对方场上有怪兽存在，自己场上没有怪兽存在的场合，可以从手卡把1只名字带有「异虫」的爬虫类族怪兽里侧守备表示特殊召唤。这个效果1回合只能使用1次。
function c28506708.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对方场上有怪兽存在，自己场上没有怪兽存在的场合，可以从手卡把1只名字带有「异虫」的爬虫类族怪兽里侧守备表示特殊召唤。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28506708,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c28506708.condition)
	e1:SetTarget(c28506708.target)
	e1:SetOperation(c28506708.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件：自己场上没有怪兽且对方场上有怪兽。
function c28506708.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上没有怪兽（我方主要怪兽区怪兽数量为0）。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 检查对方场上有怪兽（对方主要怪兽区怪兽数量不为0）。
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)~=0
end
-- 筛选符合条件的怪兽：卡名含有「异虫」、种族为爬虫类族，且可以被里侧守备表示特殊召唤。
function c28506708.filter(c,e,sp)
	return c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE) and c:IsCanBeSpecialSummoned(e,0,sp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果发动时进行合法性检查：自己场上有空余怪兽区，且手卡存在满足条件的「异虫」爬虫类族怪兽。
function c28506708.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区（空位大于0）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1张符合条件的「异虫」爬虫类族怪兽。
		and Duel.IsExistingMatchingCard(c28506708.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 将本次效果的操作信息登记为：从手卡特殊召唤1只怪兽（用于后续效果连锁判定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理时的执行函数：再次检查场上状态，若条件不满足则效果不处理。
function c28506708.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有空余怪兽区，则效果处理终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 若此时自己场上已有怪兽，则效果处理终止。
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		-- 若此时对方场上没有怪兽，则效果处理终止。
		or Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)==0 then return end
	-- 给当前玩家显示“请选择要特殊召唤的卡”的选择提示框。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1张符合条件的「异虫」爬虫类族怪兽。
	local g=Duel.SelectMatchingCard(tp,c28506708.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以里侧守备表示特殊召唤到自己的怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 将特殊召唤的里侧守备表示的怪兽展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
