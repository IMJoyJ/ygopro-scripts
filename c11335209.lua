--ホルスの祝福－ドゥアムテフ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，③的效果1回合只能使用1次。
-- ①：自己场上有「王之棺」存在的场合，这张卡可以从墓地特殊召唤。
-- ②：这张卡的攻击力·守备力上升自己场上的「荷鲁斯」怪兽数量×1200。
-- ③：这张卡在怪兽区域存在的状态，自己场上的其他卡因对方的效果从场上离开的场合才能发动。自己抽出自己的主要怪兽区域的怪兽种类的数量。
function c11335209.initial_effect(c)
	-- 将此卡登记为卡名中记载有「王之棺」（16528181）的卡片，用于规则上识别这一记载。
	aux.AddCodeList(c,16528181)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有「王之棺」存在的场合，这张卡可以从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,11335209+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c11335209.sprcon)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力·守备力上升自己场上的「荷鲁斯」怪兽数量×1200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c11335209.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 这个卡名的③的效果1回合只能使用1次。③：这张卡在怪兽区域存在的状态，自己场上的其他卡因对方的效果从场上离开的场合才能发动。自己抽出自己的主要怪兽区域的怪兽种类的数量。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(11335209,1))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,11335210)
	e4:SetCondition(c11335209.descon)
	e4:SetTarget(c11335209.destg)
	e4:SetOperation(c11335209.desop)
	c:RegisterEffect(e4)
end
-- 筛选“自己场上的「王之棺」”：要求表侧表示且卡号是16528181（王之棺）。
function c11335209.sprfilter(c)
	return c:IsFaceup() and c:IsCode(16528181)
end
-- 特殊召唤规则效果的发动条件：判断这张卡是否满足从墓地特殊召唤的规则条件——自己场上有表侧「王之棺」、主要怪兽区有空位，且墓地特殊召唤未被王家长眠之谷等效果禁止。
function c11335209.sprcon(e,c)
	if c==nil then return true end
	if c:IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	local tp=c:GetControler()
	-- 检查自己主要怪兽区是否存在可用空格。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1张表侧表示的「王之棺」（16528181）。
		and Duel.IsExistingMatchingCard(c11335209.sprfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 筛选“自己场上的「荷鲁斯」怪兽”：要求表侧表示且属于0x19d（荷鲁斯）系列字段。
function c11335209.bfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x19d)
end
-- 计算这张卡的攻击力上升数值：自己场上表侧表示「荷鲁斯」怪兽数量×1200。
function c11335209.atkval(e,c)
	-- 取得自己场上表侧表示的「荷鲁斯」怪兽数量并乘以1200，作为攻击力上升值。
	return Duel.GetMatchingGroupCount(c11335209.bfilter,c:GetControler(),LOCATION_MZONE,0,nil)*1200
end
-- 筛选因对方效果而从自己场上离开的卡：离场前控制者为自己、导致离场的玩家是对方、且离场原因为效果。
function c11335209.cfilter(c,tp)
	return c:IsPreviousControler(tp)
		and c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT)
end
-- ③效果的触发条件：同一时点离场的卡组中存在满足条件的“其他卡”，且不包含这张卡自身时才可发动。
function c11335209.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c11335209.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 筛选自己位于主要怪兽区（0-4号区域）的表侧表示怪兽，额外怪兽区（5-6号区域）不计算在内。
function c11335209.drfilter(c,tp)
	return c:GetSequence()<5 and c:IsFaceup()
end
-- 效果发动前的合法性检查：计算我方主要怪兽区域表侧表示怪兽的种类数作为抽卡张数，并确认该张数大于0且我方可以抽卡。
function c11335209.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 取得我方场上所有满足drfilter（主要怪兽区表侧表示怪兽）的卡。
		local g=Duel.GetMatchingGroup(c11335209.drfilter,tp,LOCATION_MZONE,0,nil)
		local ct=c11335209.count_unique_code(g)
		e:SetLabel(ct)
		-- 确认计算出的怪兽种类数大于0，且我方玩家可以抽相应数量的卡。
		return ct>0 and Duel.IsPlayerCanDraw(tp,ct)
	end
	-- 将当前连锁的“对象参数”设置为记录好的抽卡数，作为该连锁的参数供后续使用。
	Duel.SetTargetParam(e:GetLabel())
	-- 设置本连锁的操作信息：效果分类为抽卡（CATEGORY_DRAW），抽卡玩家为己方，抽卡数量为记录值；以便其他卡能据此对应（如“抽卡时”的诱发等检测）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,e:GetLabel())
end
-- 效果处理：重新取得我方主要怪兽区域的表侧表示怪兽组，统计其种类数，然后让己方抽取该数量的卡。
function c11335209.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得我方场上主要怪兽区域表侧表示的怪兽组（用于处理时重新计算种类数）。
	local g=Duel.GetMatchingGroup(c11335209.drfilter,tp,LOCATION_MZONE,0,nil)
	local ct=c11335209.count_unique_code(g)
	-- 让己方玩家抽取ct张卡，抽卡原因为效果（REASON_EFFECT）。
	Duel.Draw(tp,ct,REASON_EFFECT)
end
-- 统计卡片组中不同卡名的种类数：遍历每张卡的所有代码，用表去重后计数，返回种类数量。
function c11335209.count_unique_code(g)
	local check={}
	local count=0
	local tc=g:GetFirst()
	while tc do
		for i,code in ipairs({tc:GetCode()}) do
			if not check[code] then
				check[code]=true
				count=count+1
			end
		end
		tc=g:GetNext()
	end
	return count
end
