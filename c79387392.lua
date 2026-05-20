--リアクター・スライム
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。在自己场上把2只「史莱姆怪兽衍生物」（水族·水·1星·攻/守500）特殊召唤。这个回合，自己不是幻神兽族怪兽不能召唤·特殊召唤。
-- ②：自己·对方的战斗阶段把这张卡解放才能发动。从自己的手卡·卡组·墓地选1张「金属反射史莱姆」在自己的魔法与陷阱区域盖放。这个效果盖放的卡在盖放的回合也能发动。
function c79387392.initial_effect(c)
	-- ①：自己主要阶段才能发动。在自己场上把2只「史莱姆怪兽衍生物」（水族·水·1星·攻/守500）特殊召唤。这个回合，自己不是幻神兽族怪兽不能召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79387392,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,79387392)
	e1:SetTarget(c79387392.sptg)
	e1:SetOperation(c79387392.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的战斗阶段把这张卡解放才能发动。从自己的手卡·卡组·墓地选1张「金属反射史莱姆」在自己的魔法与陷阱区域盖放。这个效果盖放的卡在盖放的回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79387392,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_ATTACK+TIMING_BATTLE_END)
	e2:SetCountLimit(1,79387393)
	e2:SetCondition(c79387392.setcon)
	e2:SetCost(c79387392.setcost)
	e2:SetTarget(c79387392.settg)
	e2:SetOperation(c79387392.setop)
	c:RegisterEffect(e2)
end
-- 效果①的靶向函数，在发动时检测是否满足特殊召唤2只衍生物的条件
function c79387392.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的主要怪兽区域是否有2个以上的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查玩家是否可以特殊召唤满足特定属性、种族、攻守和等级的衍生物怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,21770261,0,TYPES_TOKEN_MONSTER,500,500,1,RACE_AQUA,ATTRIBUTE_WATER) end
	-- 向系统宣告此效果包含产生2只衍生物的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 向系统宣告此效果包含特殊召唤2只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果①的运行函数，在自己场上特殊召唤2只「史莱姆怪兽衍生物」，并适用召唤限制
function c79387392.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 在效果处理时，再次确认玩家是否可以特殊召唤该衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,21770261,0,TYPES_TOKEN_MONSTER,500,500,1,RACE_AQUA,ATTRIBUTE_WATER) then
		local ct=2
		while ct>0 do
			-- 创建卡号为79387393的「史莱姆怪兽衍生物」卡片
			local token=Duel.CreateToken(tp,79387393)
			-- 将创建的衍生物以表侧表示逐步特殊召唤到场上
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			ct=ct-1
		end
		-- 完成所有怪兽的特殊召唤步骤
		Duel.SpecialSummonComplete()
	end
	-- 这个回合，自己不是幻神兽族怪兽不能召唤·特殊召唤。自己·对方的战斗阶段把这张卡解放才能发动。从自己的手卡·卡组·墓地选1张「金属反射史莱姆」在自己的魔法与陷阱区域盖放。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c79387392.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册“不能特殊召唤幻神兽族以外的怪兽”的全局效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 给玩家注册“不能通常召唤幻神兽族以外的怪兽”的全局效果
	Duel.RegisterEffect(e2,tp)
end
-- 召唤/特殊召唤限制的过滤函数，限制非幻神兽族的怪兽
function c79387392.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsRace(RACE_DIVINE)
end
-- 效果②的发动条件函数，限制只能在自己或对方的战斗阶段发动
function c79387392.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 效果②的发动代价函数，检查并解放自身
function c79387392.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	-- 将这张卡解放作为发动的代价
	Duel.Release(c,REASON_COST)
end
-- 过滤函数，用于筛选手卡、卡组、墓地中可以盖放的「金属反射史莱姆」
function c79387392.setfilter(c)
	return c:IsCode(26905245) and c:IsSSetable()
end
-- 效果②的靶向函数，检查手卡、卡组、墓地是否存在可以盖放的「金属反射史莱姆」
function c79387392.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己的手卡、卡组、墓地是否存在至少1张满足条件的「金属反射史莱姆」
	if chk==0 then return Duel.IsExistingMatchingCard(c79387392.setfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
-- 效果②的运行函数，从手卡、卡组、墓地选择1张「金属反射史莱姆」在魔陷区盖放，并使其在盖放回合也能发动
function c79387392.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从手卡、卡组、墓地选择1张「金属反射史莱姆」（适用王家长眠之谷的过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c79387392.setfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	-- 如果成功选出卡片，则将其在自己的魔法与陷阱区域盖放
	if tc and Duel.SSet(tp,tc)~=0 then
		if tc:IsType(TYPE_QUICKPLAY) then
			-- 这个效果盖放的卡在盖放的回合也能发动。
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(79387392,2))  --"适用「增殖炉史莱姆」的效果来发动"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		if tc:IsType(TYPE_TRAP) then
			-- 这个效果盖放的卡在盖放的回合也能发动。
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(79387392,2))  --"适用「增殖炉史莱姆」的效果来发动"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
