--Witness of the Ancient
-- 效果：
-- 自己场上或墓地有同调怪兽存在的场合：可以把这张卡从手卡特殊召唤。
-- 这张卡特殊召唤的场合：可以从自己的额外卡组·墓地把最多3只卡名不同的同调怪兽当作永续魔法卡使用在自己的魔法与陷阱区域以表侧表示放置，在自己场上把持有放置数量相同等级的1只「弧光衍生物」（机械族·光·攻/守0）特殊召唤，这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
-- 「远古者的见证人」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化这张卡的两个效果：e1为手卡中的起动效果，分类为特殊召唤，1回合1次，附带发动条件、目标与处理函数；e2为这张卡特殊召唤成功时触发的诱发选发效果（场合型），分类为特殊召唤与衍生物，1回合1次，附带目标与处理函数，并将两个效果注册给这张卡
function s.initial_effect(c)
	-- 自己场上或墓地有同调怪兽存在的场合：可以把这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这张卡特殊召唤的场合：可以从自己的额外卡组·墓地把最多3只卡名不同的同调怪兽当作永续魔法卡使用在自己的魔法与陷阱区域以表侧表示放置，在自己场上把持有放置数量相同等级的1只「弧光衍生物」（机械族·光·攻/守0）特殊召唤，这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"放置怪兽"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数：卡为表侧表示且是同调怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 定义第一个效果的发动条件：检查自己场上或墓地是否存在同调怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的主要怪兽区或墓地是否存在至少1只表侧表示的同调怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
-- 定义第一个效果的目标处理：发动条件确认时检查主要怪兽区有空位且这张卡可以被特殊召唤，并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件确认时，要求自己主要怪兽区有可用的空格子
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：确定要把这张卡特殊召唤1张
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义第一个效果的处理：取得这张卡，若它仍与当前连锁相关则将其特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 把这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义可放置卡的过滤函数：卡为同调怪兽、未被禁止放置到场上、且在魔法与陷阱区域不存在同名卡
function s.placefilter(c,tp)
	return c:IsType(TYPE_SYNCHRO) and not c:IsForbidden()
		and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
-- 定义第二个效果的目标处理：检索额外卡组与墓地中可放置的同调怪兽并统计不同卡名数，按魔法与陷阱区空位与上限3修正数量，并逐一检查能否特殊召唤对应等级的衍生物；发动条件确认时要求魔法与陷阱区和主要怪兽区均有空位且存在可特招的衍生物等级
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local res=false
	-- 从自己额外卡组与墓地检索满足可放置条件的同调怪兽
	local g=Duel.GetMatchingGroup(s.placefilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,nil,tp)
	local ct=g:GetClassCount(Card.GetCode)
	-- 若可放置的不同卡名数量超过魔法与陷阱区的空位数，则将数量修正为空位数
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<ct then ct=Duel.GetLocationCount(tp,LOCATION_SZONE) end
	if ct>3 then ct=3 end
	for i=1,ct do
		-- 检查是否可以特殊召唤等级为i的「弧光衍生物」（机械族·光属性）
		if Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,i,RACE_MACHINE,ATTRIBUTE_LIGHT) then
			res=true
			break
		end
	end
	-- 发动条件确认时，要求自己魔法与陷阱区有可用的空格子
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且自己主要怪兽区有可用的空格子
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and res end
	-- 设置操作信息：预计要处理1张衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：预计要进行1次特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 定义选择子卡组时的检查函数：所选卡的卡名互不相同，且可以特殊召唤等级等于所选数量的「弧光衍生物」
function s.gcheck(g,tp)
	-- 要求所选卡片组满足卡名互不相同，并且能特殊召唤等级等于所选数量的机械族·光属性衍生物
	return aux.dncheck(g) and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,g:GetCount(),RACE_MACHINE,ATTRIBUTE_LIGHT)
end
-- 定义第二个效果的处理：魔法与陷阱区有空位时确定可放置数量（上限3），检索可放置的同调怪兽，由玩家选择1到ft只卡名不同的怪兽，将它们表侧表示放置到魔法与陷阱区并当作永续魔法卡使用；之后若主要怪兽区有空位且可特殊召唤对应等级的衍生物，则生成等级等于放置数量的「弧光衍生物」并将其特殊召唤
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 确认自己魔法与陷阱区有可用的空格子才继续处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 取得自己魔法与陷阱区当前的可用空位数，作为可放置数量的基准
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if ft>3 then ft=3 end
		-- 从自己额外卡组与墓地检索满足可放置条件且不受王家长眠之谷影响的同调怪兽
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.placefilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,nil,tp)
		if g:GetCount()>0 then
			-- 向玩家发送选择提示：请选择要放置到场上的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
			local sg=g:SelectSubGroup(tp,s.gcheck,false,1,ft,tp)
			-- 遍历玩家选出的每张同调怪兽
			for tc in aux.Next(sg) do
				-- 把该怪兽以表侧表示移动到自己魔法与陷阱区域并使其效果立刻适用
				Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
				-- 当作永续魔法卡使用在自己的魔法与陷阱区域以表侧表示放置
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetCode(EFFECT_CHANGE_TYPE)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
				e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
				tc:RegisterEffect(e1)
			end
			-- 确认自己主要怪兽区有可用的空格子
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 并确认可以特殊召唤等级等于放置数量的机械族·光属性「弧光衍生物」
				and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,sg:GetCount(),RACE_MACHINE,ATTRIBUTE_LIGHT) then
				-- 在自己场上生成1只「弧光衍生物」
				local token=Duel.CreateToken(tp,id+o)
				-- 在自己场上把持有放置数量相同等级的1只「弧光衍生物」（机械族·光·攻/守0）特殊召唤
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_LEVEL)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
				e1:SetValue(sg:GetCount())
				token:RegisterEffect(e1,true)
				-- 把这只「弧光衍生物」以表侧表示特殊召唤到自己场上
				Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把这个特殊召唤限制效果注册给自己玩家，直到回合结束时适用
	Duel.RegisterEffect(e1,tp)
end
-- 定义限制对象：额外卡组的非同调怪兽（即不能从额外卡组特殊召唤非同调怪兽）
function s.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
