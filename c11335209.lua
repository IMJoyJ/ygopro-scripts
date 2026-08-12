--ホルスの祝福－ドゥアムテフ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，③的效果1回合只能使用1次。
-- ①：自己场上有「王之棺」存在的场合，这张卡可以从墓地特殊召唤。
-- ②：这张卡的攻击力·守备力上升自己场上的「荷鲁斯」怪兽数量×1200。
-- ③：这张卡在怪兽区域存在的状态，自己场上的其他卡因对方的效果从场上离开的场合才能发动。自己抽出自己的主要怪兽区域的怪兽种类的数量。
function c11335209.initial_effect(c)
	-- 为卡片注册关联卡片代码16528181（王之棺）以便后续检查
	aux.AddCodeList(c,16528181)
	-- ①：自己场上有「王之棺」存在的场合，这张卡可以从墓地特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,11335209+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c11335209.sprcon)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力·守备力上升自己场上的「荷鲁斯」怪兽数量×1200
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
	-- ③：这张卡在怪兽区域存在的状态，自己场上的其他卡因对方的效果从场上离开的场合才能发动。自己抽出自己的主要怪兽区域的怪兽种类的数量
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
-- 特殊召唤条件过滤函数，用于检查场上是否存在「王之棺」
function c11335209.sprfilter(c)
	return c:IsFaceup() and c:IsCode(16528181)
end
-- 特殊召唤条件函数，判断是否满足特殊召唤条件
function c11335209.sprcon(e,c)
	if c==nil then return true end
	if c:IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	local tp=c:GetControler()
	-- 检查当前玩家主要怪兽区是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查当前玩家场上是否存在至少1张「王之棺」
		and Duel.IsExistingMatchingCard(c11335209.sprfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 攻击力计算过滤函数，用于筛选场上「荷鲁斯」怪兽
function c11335209.bfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x19d)
end
-- 攻击力计算函数，返回场上「荷鲁斯」怪兽数量乘以1200
function c11335209.atkval(e,c)
	-- 计算场上「荷鲁斯」怪兽数量
	return Duel.GetMatchingGroupCount(c11335209.bfilter,c:GetControler(),LOCATION_MZONE,0,nil)*1200
end
-- 离开场上的卡过滤函数，用于筛选因对方效果离开的卡
function c11335209.cfilter(c,tp)
	return c:IsPreviousControler(tp)
		and c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT)
end
-- 效果发动条件函数，判断是否有对方效果导致卡离开场
function c11335209.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c11335209.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 抽卡目标过滤函数，用于筛选场上正面表示的怪兽
function c11335209.drfilter(c,tp)
	return c:GetSequence()<5 and c:IsFaceup()
end
-- 效果目标设定函数，计算并设置要抽卡的数量
function c11335209.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取场上正面表示的怪兽组
		local g=Duel.GetMatchingGroup(c11335209.drfilter,tp,LOCATION_MZONE,0,nil)
		local ct=c11335209.count_unique_code(g)
		e:SetLabel(ct)
		-- 检查是否可以抽卡
		return ct>0 and Duel.IsPlayerCanDraw(tp,ct)
	end
	-- 设置效果目标参数为抽卡数量
	Duel.SetTargetParam(e:GetLabel())
	-- 设置效果操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,e:GetLabel())
end
-- 效果处理函数，执行抽卡操作
function c11335209.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上正面表示的怪兽组
	local g=Duel.GetMatchingGroup(c11335209.drfilter,tp,LOCATION_MZONE,0,nil)
	local ct=c11335209.count_unique_code(g)
	-- 执行抽卡操作，抽卡数量为计算出的种类数
	Duel.Draw(tp,ct,REASON_EFFECT)
end
-- 计算怪兽数量的函数，用于统计种类数
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
