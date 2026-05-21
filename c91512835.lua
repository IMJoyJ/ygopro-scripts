--インセクト女王
-- 效果：
-- ①：这张卡的攻击力上升场上的昆虫族怪兽数量×200。
-- ②：这张卡的攻击宣言之际，自己必须把自己场上1只其他怪兽解放。
-- ③：这张卡战斗破坏对方怪兽的回合的结束阶段发动。在自己场上把1只「昆虫怪兽衍生物」（昆虫族·地·1星·攻/守100）攻击表示特殊召唤。
function c91512835.initial_effect(c)
	-- ②：这张卡的攻击宣言之际，自己必须把自己场上1只其他怪兽解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ATTACK_COST)
	e1:SetCost(c91512835.atcost)
	e1:SetOperation(c91512835.atop)
	c:RegisterEffect(e1)
	-- ①：这张卡的攻击力上升场上的昆虫族怪兽数量×200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c91512835.value)
	c:RegisterEffect(e2)
	-- ③：这张卡战斗破坏对方怪兽的回合
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetOperation(c91512835.regop)
	c:RegisterEffect(e3)
	-- ③：这张卡战斗破坏对方怪兽的回合的结束阶段发动。在自己场上把1只「昆虫怪兽衍生物」（昆虫族·地·1星·攻/守100）攻击表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(91512835,0))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCountLimit(1)
	e4:SetCondition(c91512835.spcon)
	e4:SetTarget(c91512835.sptg)
	e4:SetOperation(c91512835.spop)
	c:RegisterEffect(e4)
end
-- 攻击宣言代价检查函数：检查自己场上是否存在除自身以外的可解放怪兽
function c91512835.atcost(e,c,tp)
	-- 检查自己场上是否存在至少1只除自身以外的可解放怪兽（作为攻击宣言的动作代价）
	return Duel.CheckReleaseGroupEx(tp,nil,1,REASON_ACTION,false,e:GetHandler())
end
-- 攻击宣言代价执行函数：选择并解放自己场上1只除自身以外的怪兽
function c91512835.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家选择自己场上1只除自身以外的可解放怪兽
	local g=Duel.SelectReleaseGroupEx(tp,nil,1,1,REASON_ACTION,false,e:GetHandler())
	-- 解放选中的怪兽
	Duel.Release(g,REASON_ACTION)
end
-- 过滤函数：场上表侧表示的昆虫族怪兽
function c91512835.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 攻击力上升值计算函数：根据场上昆虫族怪兽数量计算上升数值
function c91512835.value(e,c)
	-- 返回双方场上表侧表示的昆虫族怪兽数量乘以200的数值
	return Duel.GetMatchingGroupCount(c91512835.filter,0,LOCATION_MZONE,LOCATION_MZONE,nil)*200
end
-- 战斗破坏怪兽时的注册函数：给自身注册一个在回合结束阶段前有效的标志（Flag）
function c91512835.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(91512835,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 特殊召唤效果发动条件：检查自身是否在本回合注册了战斗破坏怪兽的标志
function c91512835.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(91512835)~=0
end
-- 特殊召唤效果目标函数：设置特殊召唤和产生衍生物的操作信息
function c91512835.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：产生1张衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 特殊召唤效果执行函数：在自己场上将1只「昆虫怪兽衍生物」攻击表示特殊召唤
function c91512835.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽区域是否有空位，若无则返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查玩家是否可以特殊召唤指定的衍生物怪兽，若不能则返回
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,91512836,0,TYPES_TOKEN_MONSTER,100,100,1,RACE_INSECT,ATTRIBUTE_EARTH,POS_FACEUP_ATTACK) then return end
	-- 创建卡号为91512836的衍生物卡片对象
	local token=Duel.CreateToken(tp,91512836)
	-- 将创建的衍生物以攻击表示特殊召唤到自己场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
end
