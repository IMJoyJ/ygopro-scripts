--ゼータ・レティキュラント
-- 效果：
-- ①：这张卡在墓地存在，每次对方场上的怪兽被除外发动。在自己场上把1只「地外生命衍生物」（恶魔族·暗·2星·攻/守500）特殊召唤。
-- ②：这张卡可以把自己场上1只「地外生命衍生物」解放，从手卡特殊召唤。
function c64382839.initial_effect(c)
	-- ①：这张卡在墓地存在，每次对方场上的怪兽被除外发动。在自己场上把1只「地外生命衍生物」（恶魔族·暗·2星·攻/守500）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64382839,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EVENT_REMOVE)
	e1:SetCondition(c64382839.spcon)
	e1:SetTarget(c64382839.sptg)
	e1:SetOperation(c64382839.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡可以把自己场上1只「地外生命衍生物」解放，从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c64382839.hspcon)
	e2:SetTarget(c64382839.hsptg)
	e2:SetOperation(c64382839.hspop)
	c:RegisterEffect(e2)
end
-- 过滤条件：原本由对方控制且原本存在于场上的非衍生物怪兽
function c64382839.cfilter(c,tp)
	return c:IsPreviousControler(1-tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_TOKEN)
end
-- 发动条件：检查被除外的卡中是否存在满足过滤条件的怪兽
function c64382839.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c64382839.cfilter,1,nil,tp)
end
-- 效果1的发动准备：设置特殊召唤衍生物的操作信息
function c64382839.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：生成衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果1的处理：在自己场上特殊召唤1只「地外生命衍生物」
function c64382839.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查玩家是否可以特殊召唤该衍生物，若不能则返回
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,64382840,0,TYPES_TOKEN_MONSTER,500,500,2,RACE_FIEND,ATTRIBUTE_DARK) then return end
	-- 创建「地外生命衍生物」的卡片数据
	local token=Duel.CreateToken(tp,64382840)
	-- 将衍生物以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：卡名为「地外生命衍生物」且解放后能空出怪兽区域的卡
function c64382839.spfilter(c,tp)
	return c:IsCode(64382840)
		-- 检查解放该卡后是否有可用的怪兽区域，且该卡由自己控制或在场上表侧表示
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 手卡特殊召唤规则的条件：检查场上是否存在可解放的「地外生命衍生物」
function c64382839.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否存在至少1张满足过滤条件的可解放卡片
	return Duel.CheckReleaseGroupEx(tp,c64382839.spfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 手卡特殊召唤规则的目标：选择要解放的「地外生命衍生物」
function c64382839.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取场上所有可解放的卡片，并过滤出符合条件的「地外生命衍生物」
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c64382839.spfilter,nil,tp)
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 手卡特殊召唤规则的操作：解放选中的衍生物
function c64382839.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选中的卡片
	Duel.Release(g,REASON_SPSUMMON)
end
