--E-HERO ネオス・ロード
-- 效果：
-- 「元素英雄 新宇侠」（或者有那个卡名记述的融合怪兽）＋场上的效果怪兽
-- 这张卡用「暗黑融合」的效果才能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合或者这张卡在怪兽区域存在的状态有怪兽被送去对方墓地的场合，以对方场上1只表侧表示怪兽为对象才能发动。得到那只怪兽的控制权。
-- ②：场上的这张卡不会被战斗·效果破坏。
local s,id,o=GetID()
-- 初始化卡片效果，注册融合素材代码列表，设置融合召唤条件，启用特殊召唤限制
function s.initial_effect(c)
	-- 为卡片注册「元素英雄 新宇侠」和「元素英雄 新宇侠」的融合怪兽作为可记述卡名
	aux.AddCodeList(c,94820406,89943723)
	-- 为卡片添加融合召唤所需素材代码列表，指定为「元素英雄 新宇侠」
	aux.AddMaterialCodeList(c,89943723)
	-- 设置融合召唤程序，使用「元素英雄 新宇侠」或其融合怪兽作为融合素材，配合matfilter1和matfilter2进行过滤
	aux.AddFusionProcCodeFun(c,{89943723,s.matfilter1},s.matfilter2,1,true,true)
	c:EnableReviveLimit()
	-- 设置特殊召唤条件，限制只能通过「暗黑融合」或「暗黑神召」的效果特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为使用暗黑融合限制函数，确保只能通过暗黑融合特殊召唤
	e1:SetValue(aux.DarkFusionLimit)
	c:RegisterEffect(e1)
	-- 设置效果①：在特殊召唤成功时发动，以对方场上1只表侧表示怪兽为对象，获得其控制权
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"获取控制权"
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.contg)
	e2:SetOperation(s.conop)
	c:RegisterEffect(e2)
	-- 设置效果①：在己方怪兽被送去墓地时发动，以对方场上1只表侧表示怪兽为对象，获得其控制权
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"获取控制权"
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
	-- 设置效果②：场上的这张卡不会被战斗破坏
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
-- 定义融合素材过滤函数1，用于筛选「元素英雄 新宇侠」的融合怪兽
function s.matfilter1(c)
	-- 筛选出记述了「元素英雄 新宇侠」卡名且为融合怪兽的卡片
	return aux.IsCodeListed(c,89943723) and c:IsType(TYPE_FUSION)
end
-- 定义融合素材过滤函数2，用于筛选场上的效果怪兽
function s.matfilter2(c)
	return c:IsFusionType(TYPE_EFFECT) and c:IsLocation(LOCATION_ONFIELD)
end
-- 定义条件过滤函数，用于筛选对方场上的怪兽
function s.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsControler(1-tp)
end
-- 条件函数，判断是否有对方怪兽被送去墓地
function s.concon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 控制权变更过滤函数，用于筛选可改变控制权的表侧表示怪兽
function s.confilter(c)
	return c:IsControlerCanBeChanged() and c:IsFaceup()
end
-- 设置效果①的发动时选择目标，选择对方场上1只表侧表示怪兽
function s.contg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.confilter(chkc) end
	-- 判断是否满足选择目标的条件，即对方场上是否存在可改变控制权的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.confilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只表侧表示怪兽作为目标
	local g=Duel.SelectTarget(tp,s.confilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，确定将要改变控制权的怪兽数量和类型
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 设置效果①的处理函数，执行获得目标怪兽控制权的操作
function s.conop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsType(TYPE_MONSTER) and tc:IsRelateToEffect(e) then
		-- 执行获得目标怪兽控制权的操作
		Duel.GetControl(tc,tp)
	end
end
