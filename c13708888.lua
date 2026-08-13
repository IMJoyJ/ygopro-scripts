--E-HERO ネオス・ロード
-- 效果：
-- 「元素英雄 新宇侠」（或者有那个卡名记述的融合怪兽）＋场上的效果怪兽
-- 这张卡用「暗黑融合」的效果才能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合或者这张卡在怪兽区域存在的状态有怪兽被送去对方墓地的场合，以对方场上1只表侧表示怪兽为对象才能发动。得到那只怪兽的控制权。
-- ②：场上的这张卡不会被战斗·效果破坏。
local s,id,o=GetID()
-- 注册该卡的核心效果：声明与‘暗黑融合’和‘元素英雄 新宇侠’的关联，添加以‘元素英雄 新宇侠’（或记载其卡名的融合怪兽）＋场上效果怪兽为素材的融合召唤手续并设置苏生限制；再设置‘只能用暗黑融合的效果特殊召唤’的召唤条件；随后注册①效果的两个分支（特殊召唤成功时、有此卡在怪兽区域且有怪兽被送去对方墓地时），二者共用1回合1次，取对象获得对方怪兽控制权；最后注册②效果：场上的此卡不会被战斗·效果破坏。
function s.initial_effect(c)
	-- 登记这张卡效果文本中提到的‘暗黑融合’（94820406）和‘元素英雄 新宇侠’（89943723）的卡号，使相关判定能识别这些卡名记载。
	aux.AddCodeList(c,94820406,89943723)
	-- 将‘元素英雄 新宇侠’声明为这张卡的融合素材卡名（并自动加入卡名列表），使其可作为本卡的融合素材使用。
	aux.AddMaterialCodeList(c,89943723)
	-- 添加融合召唤手续：以‘元素英雄 新宇侠’（或卡名中记载有该卡名的融合怪兽）1只＋场上的效果怪兽1只作为融合素材，并允许使用融合素材代用品。
	aux.AddFusionProcCodeFun(c,{89943723,s.matfilter1},s.matfilter2,1,true,true)
	c:EnableReviveLimit()
	-- 这张卡用「暗黑融合」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件判定为暗黑融合专用限制：只有通过‘暗黑融合’的效果或其关联的特殊召唤方式才能将这张卡特殊召唤。
	e1:SetValue(aux.DarkFusionLimit)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡特殊召唤的场合，以对方场上1只表侧表示怪兽为对象才能发动。得到那只怪兽的控制权。
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
	-- 或者这张卡在怪兽区域存在的状态有怪兽被送去对方墓地的场合，以对方场上1只表侧表示怪兽为对象才能发动。得到那只怪兽的控制权。
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
	-- ②：场上的这张卡不会被战斗·效果破坏。
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
-- 定义融合素材过滤函数1：用于筛选‘元素英雄 新宇侠’以外的替代融合素材，要求该怪兽的效果文本中记载有‘元素英雄 新宇侠’的卡名且为融合怪兽。
function s.matfilter1(c)
	-- 判断该融合怪兽是否在卡名/文本中记载了‘元素英雄 新宇侠’（卡号89943723）且自身是融合怪兽，即对应‘有那个卡名记述的融合怪兽’。
	return aux.IsCodeListed(c,89943723) and c:IsType(TYPE_FUSION)
end
-- 定义融合素材过滤函数2：素材必须为效果怪兽且位于场上，对应融合素材条件中的‘场上的效果怪兽’。
function s.matfilter2(c)
	return c:IsFusionType(TYPE_EFFECT) and c:IsLocation(LOCATION_ONFIELD)
end
-- 定义过滤函数：检查一张卡是否为怪兽，且其控制者是对方（1-tp）；用于判断送去对方墓地的怪兽是否属于对方。
function s.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsControler(1-tp)
end
-- 定义①效果第二分支（有怪兽被送去对方墓地）的发动条件：本次被送去墓地的怪兽群中至少存在1只控制者为对方的怪兽。
function s.concon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 定义取对象的选择条件：目标必须是对方场上的表侧表示怪兽，且控制权可以被改变（没有‘不能变更控制权’等限制）。
function s.confilter(c)
	return c:IsControlerCanBeChanged() and c:IsFaceup()
end
-- 定义①效果的目标选择与发动条件函数：先进行发动合法性检查（存在合法对象），然后提示玩家从对方场上选择1只表侧且可变更控制权的怪兽，并登记为效果对象及设置‘获得控制权’的操作信息。
function s.contg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.confilter(chkc) end
	-- 在效果发动时（chk==0）检查对方场上是否存在至少1只可成为对象的表侧表示怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(s.confilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示‘请选择要改变控制权的怪兽’的选择提示，用于选择卡牌时的UI引导。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让玩家从对方场上选择1只满足条件的怪兽作为效果对象，并将该对象登记为当前连锁的取对象目标。
	local g=Duel.SelectTarget(tp,s.confilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 将当前连锁的操作信息设置为‘获得控制权’（CATEGORY_CONTROL），目标为所选择的怪兽，数量为1，供其他卡的效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 定义①效果的处理函数：从连锁中取得对象，确认目标仍是怪兽且与本效果保持关联后，将其控制权转移给发动玩家。
function s.conop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的第一张效果对象卡，即之前选择的对方场上怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsType(TYPE_MONSTER) and tc:IsRelateToEffect(e) then
		-- 使tp玩家获得目标怪兽tc的控制权。
		Duel.GetControl(tc,tp)
	end
end
