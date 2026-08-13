--悪魔獣デビルゾア
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：对方场上有怪兽存在的场合，这张卡可以不用解放作召唤。
-- ②：这张卡在手卡存在的场合才能发动。这张卡守备表示特殊召唤。自己墓地没有「金属化·强化反射装甲」存在的场合，再让对方可以从自身手卡把1只怪兽特殊召唤。
-- ③：自己主要阶段才能发动。从卡组把1张「金属化」陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 向此卡注册全部效果：登记卡名「金属化·强化反射装甲」的关联，并创建e1（①无解放召唤规则）、e2（②手牌起动特殊召唤）、e3（③盖放「金属化」陷阱）三个效果。
function s.initial_effect(c)
	-- 将「金属化·强化反射装甲」（密码89812483）作为此卡效果文本中记载的卡名登记到代码列表，用于相关判断/检索。
	aux.AddCodeList(c,89812483)
	-- ①：对方场上有怪兽存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"不用解放作招唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.ntcon)
	c:RegisterEffect(e1)
	-- ②：这张卡在手卡存在的场合才能发动。这张卡守备表示特殊召唤。自己墓地没有「金属化·强化反射装甲」存在的场合，再让对方可以从自身手卡把1只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：自己主要阶段才能发动。从卡组把1张「金属化」陷阱卡在自己场上盖放。
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
-- 作为无解放通常召唤规则效果的条件函数：判断能否进行无解放召唤，包括c为空时的规则询问、目标怪兽为这张卡、无解放、等级5以上、自己怪兽区有空位且对方场上有怪兽。
function s.ntcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 要求进行无解放通常召唤（minc==0），此卡等级在5以上，且自己场上有空余的怪兽格。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 追加要求对方场上有怪兽存在，从而满足①的“对方场上有怪兽存在的场合”才能无解放召唤的条件。
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- ②效果的发动条件检查：自己场上有空余怪兽区，且手牌的这张卡能够以表侧守备表示特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认自己场上存在可用的怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 将本次连锁的操作信息登记为特殊召唤此卡1只，使其他卡能根据该信息进行连锁/判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 筛选对方手牌中可由对方玩家用此效果特殊召唤的怪兽（选择对方手牌中的怪兽并由对方特招）。
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,1-tp,false,false)
end
-- 处理②效果：首先将此卡守备表示特殊召唤；若成功且墓地没有「金属化·强化反射装甲」、对方场上有空位、对方手牌有可特招怪兽，则询问对方是否特招，并在同意后让其从手牌特招1只怪兽。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与该效果关联（未被无效/离场），然后将其以表侧守备表示特殊召唤到自己场上，且召唤成功（返回值非0）是后续追加处理的前提。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0
		-- 确认此卡特殊召唤后仍留在怪兽区，并且自己的墓地没有「金属化·强化反射装甲」（密码89812483），即满足“自己墓地没有...存在的场合”的追加条件。
		and c:IsLocation(LOCATION_MZONE) and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,89812483)
		-- 确认对方场上有可用的怪兽区，供对方从手卡特殊召唤怪兽使用。
		and Duel.GetMZoneCount(1-tp,nil,1-tp)>0
		-- 确认对方手牌中存在至少1只满足条件（可被该效果特殊召唤）的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,0,LOCATION_HAND,1,nil,e,tp)
		-- 询问对方是否要从其手卡把1只怪兽特殊召唤；只有对方选择“是”才继续追加处理。
		and Duel.SelectYesNo(1-tp,aux.Stringid(id,3)) then  --"是否特殊召唤？"
		-- 中断当前效果的处理链，使之后让对方特招的处理与前段特招错开时点，符合规则上的连续处理。
		Duel.BreakEffect()
		-- 向对方玩家发出选择提示，要求其选择要特殊召唤的手牌怪兽（选择界面显示“请选择要特殊召唤的卡”）。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 由对方玩家从其手牌中选出1只满足条件的怪兽，并获得该卡对象。
		local tc=Duel.SelectMatchingCard(1-tp,s.spfilter,tp,0,LOCATION_HAND,1,1,nil,e,tp):GetFirst()
		-- 将对方选出的那只怪兽由对方玩家以表侧攻击表示（POS_FACEUP）特殊召唤到对方场上。
		Duel.SpecialSummon(tc,0,1-tp,1-tp,false,false,POS_FACEUP)
	end
end
-- 筛选卡组中可被盖放的「金属化」系列陷阱卡：属于0x1ba字段、陷阱卡类型、且当前允许盖放到魔法陷阱区。
function s.setfilter(c)
	return c:IsSetCard(0x1ba) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- ③效果的发动条件检查：自己魔陷区有空位，且卡组存在至少1张符合条件的「金属化」陷阱卡。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动时确认自己魔法陷阱区存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 同时确认卡组中存在符合条件的「金属化」陷阱卡。
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 处理③效果：从自己卡组选择1张符合条件的「金属化」陷阱卡，盖放到自己的魔法陷阱区。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认自己魔陷区仍有空格；若已无空位则直接中断（不进行盖放）。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 向自己发出选择提示，要求选择要盖放的卡（提示文字“请选择要盖放的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己卡组中选出1张符合条件的「金属化」陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将所选陷阱卡盖放到自己场上（魔法陷阱区）。
		Duel.SSet(tp,tc)
	end
end
