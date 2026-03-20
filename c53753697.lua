--悪魔獣デビルゾア
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：对方场上有怪兽存在的场合，这张卡可以不用解放作召唤。
-- ②：这张卡在手卡存在的场合才能发动。这张卡守备表示特殊召唤。自己墓地没有「金属化·强化反射装甲」存在的场合，再让对方可以从自身手卡把1只怪兽特殊召唤。
-- ③：自己主要阶段才能发动。从卡组把1张「金属化」陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化效果函数，注册三个效果：①不用解放作召唤、②手卡特殊召唤并可能让对方特殊召唤怪兽、③主要阶段盖放金属化陷阱
function s.initial_effect(c)
	-- 记录该卡拥有「金属化·强化反射装甲」的卡名代码，用于效果判定
	aux.AddCodeList(c,89812483)
	-- ①：对方场上有怪兽存在的场合，这张卡可以不用解放作召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"不用解放作招唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.ntcon)
	c:RegisterEffect(e1)
	-- ②：这张卡在手卡存在的场合才能发动。这张卡守备表示特殊召唤。自己墓地没有「金属化·强化反射装甲」存在的场合，再让对方可以从自身手卡把1只怪兽特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：自己主要阶段才能发动。从卡组把1张「金属化」陷阱卡在自己场上盖放
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"盖放「金属化」陷阱"
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
-- 判断是否满足①效果的召唤条件：不需解放、等级5以上、有怪兽区空位、对方场上存在怪兽
function s.ntcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 满足召唤条件：不需解放、等级5以上、有怪兽区空位
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 满足召唤条件：对方场上存在怪兽
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 设置②效果的发动条件：手卡有空位、自身可特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 设置②效果的发动条件：手卡有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置②效果的处理信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义②效果中对方特殊召唤怪兽的过滤函数
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,1-tp,false,false)
end
-- 执行②效果的操作：将自身特殊召唤，若满足条件则让对方从手卡特殊召唤一只怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否能特殊召唤成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0
		-- 判断己方墓地没有「金属化·强化反射装甲」
		and c:IsLocation(LOCATION_MZONE) and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,89812483)
		-- 判断对方有怪兽区空位
		and Duel.GetMZoneCount(1-tp,nil,1-tp)>0
		-- 判断对方手卡有怪兽可特殊召唤
		and Duel.IsExistingMatchingCard(s.spfilter,tp,0,LOCATION_HAND,1,nil,e,tp)
		-- 询问对方是否发动特殊召唤
		and Duel.SelectYesNo(1-tp,aux.Stringid(id,3)) then  --"是否特殊召唤？"
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 提示对方选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择对方要特殊召唤的怪兽
		local tc=Duel.SelectMatchingCard(1-tp,s.spfilter,tp,0,LOCATION_HAND,1,1,nil,e,tp):GetFirst()
		-- 执行对方特殊召唤怪兽的操作
		Duel.SpecialSummon(tc,0,1-tp,1-tp,false,false,POS_FACEUP)
	end
end
-- 定义③效果中可盖放的「金属化」陷阱卡过滤函数
function s.setfilter(c)
	return c:IsSetCard(0x1ba) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 设置③效果的发动条件：魔陷区有空位、卡组有「金属化」陷阱卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 设置③效果的发动条件：魔陷区有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 设置③效果的发动条件：卡组有「金属化」陷阱卡
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 执行③效果的操作：从卡组选择一张「金属化」陷阱卡盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断魔陷区是否有空位
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要盖放的陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组选择一张「金属化」陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 执行盖放陷阱卡的操作
		Duel.SSet(tp,tc)
	end
end
