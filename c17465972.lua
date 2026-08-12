--BF－南風のアウステル
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡召唤成功时，以除外的1只自己的4星以下的「黑羽」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
-- ②：可以把墓地的这张卡除外，从以下效果选择1个发动。
-- ●选自己场上1只「黑翼龙」放置对方场上的卡数量的黑羽指示物。
-- ●给对方场上的表侧表示怪兽全部尽可能各放置1个楔指示物（最多1个）。
function c17465972.initial_effect(c)
	-- 注册「黑翼龙」的卡名，声明这张卡上记载着卡号为9012916的卡名
	aux.AddCodeList(c,9012916)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤成功时，以除外的1只自己的4星以下的「黑羽」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17465972,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c17465972.sumtg)
	e2:SetOperation(c17465972.sumop)
	c:RegisterEffect(e2)
	-- ②：可以把墓地的这张卡除外，从以下效果选择1个发动。●选自己场上1只「黑翼龙」放置对方场上的卡数量的黑羽指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(17465972,1))  --"「黑翼龙」放置指示物"
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	-- 把墓地的这张卡除外作为效果发动的代价
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c17465972.cttg1)
	e3:SetOperation(c17465972.ctop1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetDescription(aux.Stringid(17465972,2))  --"对方全部怪兽放置指示物"
	e4:SetTarget(c17465972.cttg2)
	e4:SetOperation(c17465972.ctop2)
	c:RegisterEffect(e4)
end
c17465972.mentioned_counter={
	[0x10]=true,
	[0x1002]=true,
}
-- 过滤函数：筛选表侧表示的4星以下的「黑羽」怪兽，且能以守备表示特殊召唤
function c17465972.filter(c,e,tp)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsSetCard(0x33) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动条件：除外区存在可作为对象的满足条件的「黑羽」怪兽，且自己主要怪兽区有空位
function c17465972.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c17465972.filter(chkc,e,tp) end
	-- 检查自己除外区是否存在至少1只可作为效果对象的满足条件的4星以下「黑羽」怪兽
	if chk==0 then return Duel.IsExistingTarget(c17465972.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
		-- 并且自己主要怪兽区有至少1个可用空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 向玩家提示「请选择要特殊召唤的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己除外区选择1只满足条件的4星以下「黑羽」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c17465972.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置连锁的操作信息：将对作为对象的1只卡进行特殊召唤处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 取得效果对象，若其仍与本效果关联，则将其以守备表示特殊召唤到自己场上
function c17465972.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以守备表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 过滤函数：筛选自己场上表侧表示的「黑翼龙」，且能放置指定数量的黑羽指示物
function c17465972.ctfilter1(c,ct)
	return c:IsFaceup() and c:IsCode(9012916) and c:IsCanAddCounter(0x10,ct)
end
-- 效果发动条件：对方场上的卡数量大于0且自己场上存在能放置该数量黑羽指示物的「黑翼龙」；向对方提示选择的效应并设置指示物操作信息
function c17465972.cttg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得对方场上的卡的数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	-- 检查对方场上的卡数量大于0，且自己怪兽区存在至少1只能放置该数量黑羽指示物的「黑翼龙」
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(c17465972.ctfilter1,tp,LOCATION_MZONE,0,1,nil,ct) end
	-- 向对方玩家提示自己选择了发动哪个效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁的操作信息：将放置与对方场上卡数量相同的黑羽指示物（0x10）
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,ct,0,0x10)
end
-- 若对方场上的卡数量大于0，则选择自己场上1只「黑翼龙」，为其放置该数量的黑羽指示物
function c17465972.ctop1(e,tp,eg,ep,ev,re,r,rp)
	-- 取得对方场上的卡的数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	if ct>0 then
		-- 让自己选择自己怪兽区1只能放置该数量黑羽指示物的「黑翼龙」
		local g=Duel.SelectMatchingCard(tp,c17465972.ctfilter1,tp,LOCATION_MZONE,0,1,1,nil,ct)
		local tc=g:GetFirst()
		if tc then
			tc:AddCounter(0x10,ct)
		end
	end
end
-- 过滤函数：筛选对方场上表侧表示、当前没有楔指示物且能放置1个楔指示物的怪兽
function c17465972.ctfilter2(c)
	return c:IsFaceup() and c:GetCounter(0x1002)==0 and c:IsCanAddCounter(0x1002,1)
end
-- 效果发动条件：对方场上存在能放置楔指示物的表侧表示怪兽；向对方提示选择的效应并设置楔指示物操作信息
function c17465972.cttg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方怪兽区是否存在至少1只能放置楔指示物的表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c17465972.ctfilter2,tp,0,LOCATION_MZONE,1,nil) end
	-- 向对方玩家提示自己选择了发动哪个效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁的操作信息：将放置1个楔指示物（0x1002）
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1002)
end
-- 取得对方场上所有能放置楔指示物的表侧表示怪兽，逐一各放置1个楔指示物
function c17465972.ctop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得对方场上所有满足条件（无楔指示物且能放置）的表侧表示怪兽的卡组
	local g=Duel.GetMatchingGroup(c17465972.ctfilter2,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1002,1)
		tc=g:GetNext()
	end
end
