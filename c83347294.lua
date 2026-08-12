--オッドアイズ・ランサー・ドラゴン
-- 效果：
-- ①：自己场上的灵摆怪兽被战斗·效果破坏的场合，把自己场上1只怪兽解放才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
-- ③：自己场上的「异色眼」卡被战斗·效果破坏的场合，可以作为代替把自己的手卡·怪兽区域·灵摆区域1张「异色眼」卡破坏。
function c83347294.initial_effect(c)
	-- ①：自己场上的灵摆怪兽被战斗·效果破坏的场合，把自己场上1只怪兽解放才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83347294,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c83347294.spcon)
	e1:SetCost(c83347294.spcost)
	e1:SetTarget(c83347294.sptg)
	e1:SetOperation(c83347294.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(c83347294.aclimit)
	e2:SetCondition(c83347294.actcon)
	c:RegisterEffect(e2)
	-- ③：自己场上的「异色眼」卡被战斗·效果破坏的场合，可以作为代替把自己的手卡·怪兽区域·灵摆区域1张「异色眼」卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c83347294.reptg)
	e3:SetValue(c83347294.repval)
	e3:SetOperation(c83347294.repop)
	c:RegisterEffect(e3)
end
-- 过滤因战斗或效果破坏且原本是表侧表示存在于自己场上怪兽区域的灵摆怪兽
function c83347294.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and bit.band(c:GetPreviousTypeOnField(),TYPE_PENDULUM)~=0
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP)
end
-- 检查被破坏的卡中是否存在满足条件的自己场上的灵摆怪兽
function c83347294.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c83347294.cfilter,1,nil,tp)
end
-- 过滤可作为解放代价的怪兽（若怪兽区域已满，则必须解放自己场上的怪兽）
function c83347294.rfilter(c,ft,tp)
	return (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
end
-- 效果①的代价处理：检查并从场上选择1只怪兽解放
function c83347294.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家的可用的主要怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查是否满足解放1只怪兽的条件（若怪兽区域已满，则必须解放自己场上的怪兽来腾出位置）
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c83347294.rfilter,1,nil,ft,tp) end
	-- 玩家选择1只满足条件的怪兽作为解放
	local sg=Duel.SelectReleaseGroup(tp,c83347294.rfilter,1,1,nil,ft,tp)
	-- 将选中的怪兽作为发动代价解放
	Duel.Release(sg,REASON_COST)
end
-- 效果①的靶向处理：检查这张卡是否能特殊召唤，并设置特殊召唤的操作信息
function c83347294.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息（特殊召唤1张手牌中的这张卡）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的效果处理：将这张卡从手卡特殊召唤
function c83347294.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 限制对方不能发动魔法·陷阱卡
function c83347294.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 检查当前攻击的怪兽是否是这张卡本身
function c83347294.actcon(e)
	-- 判断当前攻击的怪兽是否为这张卡
	return Duel.GetAttacker()==e:GetHandler()
end
-- 过滤需要代替破坏的、自己场上因战斗或效果被破坏的「异色眼」卡
function c83347294.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsOnField() and c:IsSetCard(0x99)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT)) and not c:IsReason(REASON_REPLACE)
end
-- 过滤可以作为代替破坏的、自己手卡·怪兽区域·灵摆区域的「异色眼」卡
function c83347294.desfilter(c,e,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_HAND+LOCATION_MZONE+LOCATION_PZONE) and c:IsSetCard(0x99)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 代替破坏效果的靶向处理：检查是否有「异色眼」卡被破坏，以及是否有可代替破坏的卡
function c83347294.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c83347294.repfilter,1,nil,tp)
		-- 检查自己的手卡、怪兽区域或灵摆区域是否存在至少1张可以被破坏的「异色眼」卡
		and Duel.IsExistingMatchingCard(c83347294.desfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_PZONE,0,1,nil,e,tp) end
	-- 询问玩家是否发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 提示玩家选择要代替破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 玩家从手卡、怪兽区域或灵摆区域选择1张「异色眼」卡作为代替破坏的卡
		local g=Duel.SelectMatchingCard(tp,c83347294.desfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_PZONE,0,1,1,nil,e,tp)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	end
	return false
end
-- 确定代替破坏效果所适用的对象（即被破坏的「异色眼」卡）
function c83347294.repval(e,c)
	return c83347294.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的效果处理：将选中的代替卡破坏
function c83347294.repop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 将作为代替的卡因效果代替破坏而破坏
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
