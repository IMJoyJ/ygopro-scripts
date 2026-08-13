--増殖
-- 效果：
-- 把自己场上表侧表示存在的1只「栗子球」解放才能发动。在自己场上把「栗子球衍生物」（恶魔族·暗·1星·攻300/守200）尽可能守备表示特殊召唤。这衍生物不能为上级召唤而解放。
function c40703222.initial_effect(c)
	-- 将「栗子球」(40640057) 记录进本卡的代码列表，视为本卡效果文字中提到的卡名，便于进行卡名记述相关的判定。
	aux.AddCodeList(c,40640057)
	-- 把自己场上表侧表示存在的1只「栗子球」解放才能发动。在自己场上把「栗子球衍生物」（恶魔族·暗·1星·攻300/守200）尽可能守备表示特殊召唤。这衍生物不能为上级召唤而解放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c40703222.cost)
	e1:SetTarget(c40703222.target)
	e1:SetOperation(c40703222.activate)
	c:RegisterEffect(e1)
end
-- 定义解放候选的过滤函数：候选卡必须是表侧表示、卡名为「栗子球」，且解放后我方场上仍有可用的怪兽区域。
function c40703222.cfilter(c,tp)
	-- 检查候选卡是否为表侧表示的「栗子球」，并且计算该卡解放后我方场上是否仍有可用的主要怪兽区域。
	return c:IsFaceup() and c:IsCode(40640057) and Duel.GetMZoneCount(tp,c)>0
end
-- 定义发动代价的处理：从我方场上选择1只满足条件的表侧表示「栗子球」解放作为发动代价。
function c40703222.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前的合法性检查：确认我方场上是否存在至少1只可解放的表侧表示「栗子球」，且解放后仍有空余怪兽区用于特殊召唤衍生物。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c40703222.cfilter,1,nil,tp) end
	-- 让玩家从满足条件的「栗子球」中选择1只作为发动代价。
	local g=Duel.SelectReleaseGroup(tp,c40703222.cfilter,1,1,nil,tp)
	-- 将选择的「栗子球」解放（送入墓地），作为发动效果所支付的代价。
	Duel.Release(g,REASON_COST)
end
-- 定义效果发动时的目标条件与操作信息：确认可以特殊召唤「栗子球衍生物」，取得可用怪兽区数量，并受「青眼精灵龙」影响时最多只能特殊召唤1只；同时设置本次效果涉及衍生物和特殊召唤的操作信息。
function c40703222.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时的目标合法性检查：当前玩家能否特殊召唤1只「栗子球衍生物」（恶魔族·暗·1星·攻300/守200）。
	if chk==0 then return Duel.IsPlayerCanSpecialSummonMonster(tp,40703223,0,TYPES_TOKEN_MONSTER,300,200,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE) end
	-- 计算我方场上当前可用的主要怪兽区域数量，用于决定特殊召唤衍生物的上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 设置本次连锁的操作信息为“生成衍生物”，预定数量为ft，供相关卡牌效果进行发动检测。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ft,0,0)
	-- 设置本次连锁的操作信息为“特殊召唤”，预定数量为ft，供相关卡牌效果进行发动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ft,0,0)
end
-- 效果处理：尽可能多地在我方场上守备表示特殊召唤「栗子球衍生物」，并为每个衍生物赋予“不能为上级召唤而解放”的永续效果。
function c40703222.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新计算我方场上可用的主要怪兽区数量（可能因连锁中的其他变化而变动）。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 若没有可用怪兽区或无法特殊召唤「栗子球衍生物」，则效果处理终止。
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,40703223,0,TYPES_TOKEN_MONSTER,300,200,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	for i=1,ft do
		-- 生成1只「栗子球衍生物」（恶魔族·暗·1星·攻300/守200）在我方场上。
		local token=Duel.CreateToken(tp,40703223)
		-- 将衍生物以表侧守备表示特殊召唤到我方场上，分步特殊召唤，需配合SpecialSummonComplete统一处理。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 这衍生物不能为上级召唤而解放。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
	end
	-- 完成分步特殊召唤的收尾，统一处理所有衍生物特殊召唤成功。
	Duel.SpecialSummonComplete()
end
