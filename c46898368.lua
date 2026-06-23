--逆巻く炎の宝札
-- 效果：
-- 这个卡名在规则上也当作「转生炎兽」卡使用。这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是炎属性怪兽不能召唤·特殊召唤。
-- ①：对方场上的卡数量比自己场上的卡多的场合，以对方场上1只连接怪兽为对象才能发动。自己抽出那只怪兽的连接标记的数量。
function c46898368.initial_effect(c)
	-- ①：对方场上的卡数量比自己场上的卡多的场合，以对方场上1只连接怪兽为对象才能发动。自己抽出那只怪兽的连接标记的数量。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,46898368+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c46898368.condition)
	e1:SetCost(c46898368.cost)
	e1:SetTarget(c46898368.target)
	e1:SetOperation(c46898368.activate)
	c:RegisterEffect(e1)
	-- 设置召唤次数计数器，用于限制发动回合内不能进行召唤或特殊召唤
	Duel.AddCustomActivityCounter(46898368,ACTIVITY_SUMMON,c46898368.counterfilter)
	-- 设置特殊召唤次数计数器，用于限制发动回合内不能进行召唤或特殊召唤
	Duel.AddCustomActivityCounter(46898368,ACTIVITY_SPSUMMON,c46898368.counterfilter)
end
-- 计数器过滤函数，仅对炎属性怪兽生效
function c46898368.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 效果发动条件：对方场上的卡数量比自己场上的卡多
function c46898368.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 比较对方场上卡数与己方场上卡数
	return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
end
-- 效果费用：确认发动回合内未进行过召唤或特殊召唤
function c46898368.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否已进行过召唤
	if chk==0 then return Duel.GetCustomActivityCount(46898368,tp,ACTIVITY_SUMMON)==0
		-- 检查是否已进行过特殊召唤
		and Duel.GetCustomActivityCount(46898368,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建并注册不能召唤和特殊召唤非炎属性怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c46898368.splimit)
	-- 将不能召唤效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	-- 将不能特殊召唤效果注册给玩家
	Duel.RegisterEffect(e2,tp)
end
-- 限制非炎属性怪兽的召唤与特殊召唤
function c46898368.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 筛选条件函数：选择对方场上的表侧表示连接怪兽且能抽卡
function c46898368.filter(c,tp)
	-- 筛选条件：必须是表侧表示的连接怪兽且该玩家可以抽对应数量的卡
	return c:IsFaceup() and c:IsType(TYPE_LINK) and Duel.IsPlayerCanDraw(tp,c:GetLink())
end
-- 设置效果目标：选择对方场上一只符合条件的连接怪兽
function c46898368.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c46898368.filter(chkc,tp) end
	-- 检查是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c46898368.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c46898368.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	local lk=g:GetFirst():GetLink()
	-- 设置效果操作信息中的目标玩家为使用效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果操作信息中的目标参数为所选怪兽的连接数
	Duel.SetTargetParam(lk)
	-- 设置效果操作信息，准备进行抽卡处理
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,lk)
end
-- 效果发动时执行的操作：将目标怪兽的连接数作为抽卡数量进行抽卡
function c46898368.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local d=tc:GetLink()
	-- 根据目标玩家和抽卡数量执行抽卡
	Duel.Draw(p,d,REASON_EFFECT)
end
