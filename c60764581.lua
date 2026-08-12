--迷える仔羊
-- 效果：
-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽召唤·反转召唤·特殊召唤。
-- ①：在自己场上把2只「羔羊衍生物」（兽族·地·1星·攻/守0）守备表示特殊召唤。
function c60764581.initial_effect(c)
	-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽召唤·反转召唤·特殊召唤。①：在自己场上把2只「羔羊衍生物」（兽族·地·1星·攻/守0）守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c60764581.cost)
	e1:SetTarget(c60764581.target)
	e1:SetOperation(c60764581.activate)
	c:RegisterEffect(e1)
end
-- 检查本回合玩家是否进行过召唤、反转召唤或特殊召唤
function c60764581.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合玩家是否进行过通常召唤
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SUMMON)==0
		-- 检查本回合玩家是否进行过反转召唤或特殊召唤
		and Duel.GetActivityCount(tp,ACTIVITY_FLIPSUMMON)==0 and Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽召唤·反转召唤·特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(c60764581.sumlimit)
	-- 给玩家注册不能特殊召唤怪兽的效果（此卡效果除外）
	Duel.RegisterEffect(e1,tp)
	-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽召唤·反转召唤·特殊召唤。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	-- 给玩家注册不能通常召唤怪兽的效果
	Duel.RegisterEffect(e2,tp)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	-- 给玩家注册不能反转召唤怪兽的效果
	Duel.RegisterEffect(e3,tp)
end
-- 限制条件：判定特殊召唤的效果是否为这张卡的效果，若不是则禁止特殊召唤
function c60764581.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return e:GetLabelObject()~=se
end
-- 效果发动时的可行性检查：检查是否不受青眼精灵龙限制、场上是否有2个以上空位，且可以特殊召唤羔羊衍生物
function c60764581.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查玩家场上的怪兽区域空位数是否大于1
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查玩家是否可以特殊召唤羔羊衍生物（兽族·地·1星·攻/守0）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,60764582,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) end
	-- 设置操作信息：产生2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息：特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果处理：在满足条件时，在自己场上把2只羔羊衍生物守备表示特殊召唤
function c60764581.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查玩家场上的怪兽区域空位数是否大于1
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查玩家是否可以特殊召唤羔羊衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,60764582,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) then
		for i=1,2 do
			-- 创建羔羊衍生物卡片
			local token=Duel.CreateToken(tp,60764581+i)
			-- 将衍生物以表侧守备表示特殊召唤（放入特殊召唤步骤）
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
		-- 完成特殊召唤的处理
		Duel.SpecialSummonComplete()
	end
end
