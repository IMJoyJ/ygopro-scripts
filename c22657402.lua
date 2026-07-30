--冥界の麗人イゾルデ
-- 效果：
-- 这张卡不用这张卡的①的方法不能特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上有「冥界骑士 崔斯坦」存在的场合，这张卡可以从手卡特殊召唤。
-- ②：以自己场上最多2只不死族怪兽为对象，宣言5～8的任意等级才能发动。那些怪兽直到回合结束时变成宣言的等级。这个效果的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
function c22657402.initial_effect(c)
	-- 这张卡不用这张卡的①的方法不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：自己场上有「冥界骑士 崔斯坦」存在的场合，这张卡可以从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c22657402.spcon)
	c:RegisterEffect(e2)
	-- ②：以自己场上最多2只不死族怪兽为对象，宣言5～8的任意等级才能发动。那些怪兽直到回合结束时变成宣言的等级。这个效果的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,22657402)
	e3:SetTarget(c22657402.target)
	e3:SetOperation(c22657402.operation)
	c:RegisterEffect(e3)
end
-- 检索满足条件的卡片组：场上有表侧表示的「冥界骑士 崔斯坦」
function c22657402.spfilter(c)
	return c:IsFaceup() and c:IsCode(96163807)
end
-- 判断特殊召唤条件是否满足：场上存在「冥界骑士 崔斯坦」且有空余怪兽区域
function c22657402.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断是否有空余怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断场上是否存在「冥界骑士 崔斯坦」
		and Duel.IsExistingMatchingCard(c22657402.spfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤函数：选择场上的不死族表侧表示怪兽
function c22657402.filter(c)
	return c:IsFaceup() and c:GetLevel()>0 and c:IsRace(RACE_ZOMBIE)
end
-- 设置效果目标并选择对象：选择1~2只不死族怪兽作为效果对象
function c22657402.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c22657402.filter(chkc) end
	-- 检查是否满足发动条件：场上存在至少1只不死族表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c22657402.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择对象：提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标怪兽：从己方场上选择1~2只不死族表侧表示怪兽
	local g=Duel.SelectTarget(tp,c22657402.filter,tp,LOCATION_MZONE,0,1,2,nil)
	local lv1=g:GetFirst():GetLevel()
	local lv2=0
	local tc2=g:GetNext()
	if tc2 then lv2=tc2:GetLevel() end
	-- 提示玩家宣言等级：提示选择等级
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	-- 让玩家宣言一个5~8之间的等级
	local lv=Duel.AnnounceLevel(tp,5,8,lv1,lv2)
	e:SetLabel(lv)
end
-- 过滤函数：筛选与效果相关的表侧表示怪兽
function c22657402.lvfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
-- 执行效果处理：将选定的怪兽等级改为宣言的等级，并设置不能特殊召唤非不死族怪兽的效果
function c22657402.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中被选择的目标怪兽组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c22657402.lvfilter,nil,e)
	local tc=g:GetFirst()
	while tc do
		-- 为每个目标怪兽设置等级改变效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
	-- 设置不能特殊召唤非不死族怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c22657402.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件函数：禁止特殊召唤非不死族怪兽
function c22657402.splimit(e,c)
	return c:GetRace()~=RACE_ZOMBIE
end
