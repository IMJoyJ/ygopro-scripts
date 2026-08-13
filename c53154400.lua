--サイコ・ローヴァー
-- 效果：
-- ①：这张卡特殊召唤成功的场合才能发动。掷1次骰子。1·6出现的场合，选场上最多2张卡破坏。
-- ②：这张卡被送去墓地的场合才能发动。掷1次骰子。2～5出现的场合，这张卡特殊召唤。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不能从额外卡组把怪兽特殊召唤。
local s,id,o=GetID()
-- 创建并注册这张卡的两个诱发选发效果：①在特殊召唤成功时掷骰子，掷出1·6则破坏场上最多2张卡；②在被送去墓地时掷骰子，掷出2～5则特殊召唤并附加额外卡组特召自肃。
function s.initial_effect(c)
	-- ①：这张卡特殊召唤成功的场合才能发动。掷1次骰子。1·6出现的场合，选场上最多2张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DICE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.dictg)
	e1:SetOperation(s.dicop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。掷1次骰子。2～5出现的场合，这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DICE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件与操作信息设置：发动时检查场上是否有卡存在；若有，则将本次连锁标记为骰子效果（由tp掷1次骰子），但不提前登记破坏对象。
function s.dictg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：双方场上合计至少存在1张卡，才能发动①效果。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 登记本次连锁的操作信息为骰子效果：由发动者tp掷1次骰子，用于配合骰子相关卡片的响应与判定。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- ①效果的处理：掷1次骰子；若结果为1或6，则从双方场上选择1～2张卡并破坏（选择在效果处理时进行，不取对象）。
function s.dicop(e,tp,eg,ep,ev,re,r,rp)
	-- 发动者tp掷1次骰子，点数存入局部变量d（1～6）。
	local d=Duel.TossDice(tp,1)
	if d==1 or d==6 then
		-- 显示‘请选择要破坏的卡’的选择提示，为随后的选卡操作设定提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从双方场上选择1～2张任意卡（aux.TRUE恒真，即不限定条件），这些卡将在本次效果中被破坏。
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
		if g:GetCount()>0 then
			-- 给所选的卡显示‘被选为对象’的提示动画，并记录这些卡为本次效果选择的对象。
			Duel.HintSelection(g)
			-- 以效果（REASON_EFFECT）为原因破坏所选的全部卡片。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- ②效果的发动条件判定：自己主要怪兽区有空位，且这张卡满足被效果特殊召唤的召唤条件时，才允许发动。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否有空格，用于确定是否能特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次连锁的操作信息：将这张卡本身作为将要特殊召唤的对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 登记本次连锁包含骰子效果：由tp掷1次骰子，用于记录和响应。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- ②效果的处理：掷骰子；若结果为2～5且这张卡仍与效果关联，则将其表侧表示特殊召唤到自己场上；若特殊召唤成功，再给它附加一个‘不能从额外卡组特殊召唤怪兽’的永续效果（自肃）。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 发动者tp掷1次骰子，点数存入局部变量d（1～6）。
	local d=Duel.TossDice(tp,1)
	if d>1 and d<6 and c:IsRelateToEffect(e)
		-- 当骰子点数为2～5（d>1且d<6）并且这张卡仍与效果关联时，将其表侧表示特殊召唤到自己场上；只有特殊召唤成功（返回值>0）才继续执行后续自肃处理。
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不能从额外卡组把怪兽特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
	end
end
-- 自肃效果的过滤函数：仅当尝试特殊召唤的怪兽位于额外卡组时，该特殊召唤行为会被禁止。
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
