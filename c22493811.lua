--アリの増殖
-- 效果：
-- 祭掉自己场上1只昆虫族怪兽发动。在自己场上特殊召唤2只「兵队衍生物」（地·4星·昆虫族·攻500·守1200）。（不能用作上级召唤的祭品）
function c22493811.initial_effect(c)
	-- 祭掉自己场上1只昆虫族怪兽发动。在自己场上特殊召唤2只「兵队衍生物」（地·4星·昆虫族·攻500·守1200）。（不能用作上级召唤的祭品）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c22493811.cost)
	e1:SetTarget(c22493811.target)
	e1:SetOperation(c22493811.activate)
	c:RegisterEffect(e1)
end
-- 定义解放对象的过滤条件：c必须是昆虫族怪兽，且解放c后我方场上仍有至少2个可用怪兽区域，并且c是我方控制或表侧表示，以保证能作为发动代价并空出足够格子特殊召唤2只衍生物。
function c22493811.costfilter(c,tp)
	return c:IsRace(RACE_INSECT)
		-- 在过滤条件中追加：解放c后我方主要怪兽区域空位数大于1（为了容纳2只衍生物），且c为我方控制或处于表侧表示。
		and Duel.GetMZoneCount(tp,c)>1 and (c:IsControler(tp) or c:IsFaceup())
end
-- 发动代价处理：先标记已通过代价判定，若在check阶段则检查能否从自己场上选出1只符合条件的昆虫族怪兽；实际发动时选择1只解放，作为效果发动的COST。
function c22493811.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 代价检查阶段：确认自己场上存在至少1只满足costfilter条件（昆虫族且解放后有空位）的可解放怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c22493811.costfilter,1,nil,tp) end
	-- 让玩家从自己场上选择1只满足costfilter条件的昆虫族怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,c22493811.costfilter,1,1,nil,tp)
	-- 将选中的昆虫族怪兽解放，作为这张卡发动的代价。
	Duel.Release(g,REASON_COST)
end
-- 发动时进行合法性判定：需要满足已支付代价时有足够空位（或当前空位>1）、没有「青眼精灵龙」适用中、且可以特殊召唤「兵队衍生物」；满足后向系统登记本次操作将产生2只衍生物并特殊召唤。
function c22493811.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算是否满足特殊召唤2只衍生物所需空位：若已经通过cost处理（e:GetLabel()==1）则视为满足，否则检查当前我方场上是否有至少2个可用怪兽区域。
	local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>1
	if chk==0 then
		e:SetLabel(0)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return res and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 确认我方能够特殊召唤「兵队衍生物」（地属性·4星·昆虫族·攻击力500·守备力1200的衍生物怪兽）。
			and Duel.IsPlayerCanSpecialSummonMonster(tp,22493812,0,TYPES_TOKEN_MONSTER,500,1200,4,RACE_INSECT,ATTRIBUTE_EARTH)
	end
	-- 登记操作信息：本次效果处理中将产生2只衍生物，用于给系统识别效果类型。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 登记操作信息：本次效果处理中将特殊召唤2只怪兽，用于给系统识别效果类型。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果处理：若「青眼精灵龙」的禁止同时特殊召唤2只以上怪兽的效果适用中则直接终止；否则在确认空位足够且可以特招衍生物后，连续特殊召唤2只「兵队衍生物」，并为每只衍生物赋予“不能作为上级召唤的解放”的永续效果，最后完成特殊召唤处理。
function c22493811.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查我方场上是否有至少2个可用怪兽区域，以确定能否特殊召唤2只衍生物。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 再次确认我方可以特殊召唤「兵队衍生物」（地·4星·昆虫族·攻500·守1200）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,22493812,0,TYPES_TOKEN_MONSTER,500,1200,4,RACE_INSECT,ATTRIBUTE_EARTH) then
		for i=1,2 do
			-- 创建1只「兵队衍生物」（卡号22493812）的衍生物怪兽。
			local token=Duel.CreateToken(tp,22493812)
			-- 通过特殊召唤步骤将衍生物以表侧攻击表示特殊召唤到我方场上（暂时进入处理队列）。
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			-- 这个衍生物不能用于上级召唤而解放。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1,true)
		end
		-- 完成这一次连锁中的全部特殊召唤步骤，统一处理衍生物的特殊召唤成功并触发相关时点。
		Duel.SpecialSummonComplete()
	end
end
