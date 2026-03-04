--E-HERO ネオス・ロード
-- 效果：
-- 「元素英雄 新宇侠」（或者有那个卡名记述的融合怪兽）＋场上的效果怪兽
-- 这张卡用「暗黑融合」的效果才能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合或者这张卡在怪兽区域存在的状态有怪兽被送去对方墓地的场合，以对方场上1只表侧表示怪兽为对象才能发动。得到那只怪兽的控制权。
-- ②：场上的这张卡不会被战斗·效果破坏。
local s,id,o=GetID()
-- 初始化卡片效果函数
function s.initial_effect(c)
	-- 为卡片注册“有卡片记述”的卡片代码列表，用于标记该卡效果中提及的「元素英雄 新宇侠」和「暗黑融合」
	aux.AddCodeList(c,94820406,89943723)
	-- 为卡片添加融合召唤所需的素材代码列表，指定融合素材为「元素英雄 新宇侠」
	aux.AddMaterialCodeList(c,89943723)
	-- 设置融合召唤的处理函数，使用指定的融合素材和过滤器进行融合召唤
	aux.AddFusionProcCodeFun(c,{89943723,s.matfilter1},s.matfilter2,1,true,true)
	c:EnableReviveLimit()
	-- 这张卡用「暗黑融合」的效果才能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为通过「暗黑融合」或「暗黑神召」的效果进行特殊召唤
	e1:SetValue(aux.DarkFusionLimit)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤的场合或者这张卡在怪兽区域存在的状态有怪兽被送去对方墓地的场合，以对方场上1只表侧表示怪兽为对象才能发动。得到那只怪兽的控制权
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.contg)
	e2:SetOperation(s.conop)
	c:RegisterEffect(e2)
	-- ①：这张卡特殊召唤的场合或者这张卡在怪兽区域存在的状态有怪兽被送去对方墓地的场合，以对方场上1只表侧表示怪兽为对象才能发动。得到那只怪兽的控制权
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.concon)
	e3:SetTarget(s.contg)
	e3:SetOperation(s.conop)
	c:RegisterEffect(e3)
	-- ②：场上的这张卡不会被战斗·效果破坏
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e5)
end
s.dark_calling=true
s.material_setcode=0x8
-- 定义融合素材过滤器1，用于筛选「元素英雄 新宇侠」类型的融合怪兽
function s.matfilter1(c)
	-- 返回是否为「元素英雄 新宇侠」且为融合怪兽
	return aux.IsCodeListed(c,89943723) and c:IsType(TYPE_FUSION)
end
-- 定义融合素材过滤器2，用于筛选场上的效果怪兽
function s.matfilter2(c)
	return c:IsFusionType(TYPE_EFFECT) and c:IsLocation(LOCATION_ONFIELD)
end
-- 定义卡片过滤器，用于判断是否为对方控制的怪兽
function s.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsControler(1-tp)
end
-- 定义触发条件函数，用于判断是否有对方怪兽被送去墓地
function s.concon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 定义控制权变更过滤器，用于筛选可以改变控制权的表侧表示怪兽
function s.confilter(c)
	return c:IsControlerCanBeChanged() and c:IsFaceup()
end
-- 定义选择目标函数，用于选择对方场上的表侧表示怪兽
function s.contg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.confilter(chkc) end
	-- 检查是否有满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(s.confilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	-- 选择对方场上的表侧表示怪兽作为目标
	local g=Duel.SelectTarget(tp,s.confilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，指定将要改变控制权的怪兽
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 定义效果处理函数，用于执行控制权变更操作
function s.conop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsType(TYPE_MONSTER) and tc:IsRelateToEffect(e) then
		-- 将目标怪兽的控制权转移给指定玩家
		Duel.GetControl(tc,tp)
	end
end
