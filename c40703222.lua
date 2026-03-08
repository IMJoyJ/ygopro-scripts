--増殖
-- 效果：
-- 把自己场上表侧表示存在的1只「栗子球」解放才能发动。在自己场上把「栗子球衍生物」（恶魔族·暗·1星·攻300/守200）尽可能守备表示特殊召唤。这衍生物不能为上级召唤而解放。
function c40703222.initial_effect(c)
	-- 记录此卡效果中涉及的「栗子球」卡片密码
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
-- 定义用于筛选场上符合条件的「栗子球」的过滤函数
function c40703222.cfilter(c,tp)
	-- 筛选场上表侧表示、卡片密码为「栗子球」且怪兽区有空位的卡
	return c:IsFaceup() and c:IsCode(40640057) and Duel.GetMZoneCount(tp,c)>0
end
-- 定义此卡发动时的费用支付函数
function c40703222.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足支付费用的条件：场上存在至少1张符合条件的「栗子球」
	if chk==0 then return Duel.CheckReleaseGroup(tp,c40703222.cfilter,1,nil,tp) end
	-- 从场上选择1张符合条件的「栗子球」作为支付费用的卡
	local g=Duel.SelectReleaseGroup(tp,c40703222.cfilter,1,1,nil,tp)
	-- 将选中的卡进行解放作为支付费用
	Duel.Release(g,REASON_COST)
end
-- 定义此卡发动时的目标选择函数
function c40703222.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以特殊召唤「栗子球衍生物」
	if chk==0 then return Duel.IsPlayerCanSpecialSummonMonster(tp,40703223,0,TYPES_TOKEN_MONSTER,300,200,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE) end
	-- 获取玩家场上可用的怪兽区数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 设置连锁操作信息：将要特殊召唤的衍生物数量
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ft,0,0)
	-- 设置连锁操作信息：将要特殊召唤的衍生物数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ft,0,0)
end
-- 定义此卡发动时的主要处理函数
function c40703222.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 判断是否满足特殊召唤的条件：怪兽区有空位且可以特殊召唤衍生物
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,40703223,0,TYPES_TOKEN_MONSTER,300,200,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	for i=1,ft do
		-- 创建一张「栗子球衍生物」
		local token=Duel.CreateToken(tp,40703223)
		-- 将创建的衍生物以守备表示特殊召唤到场上
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 为特殊召唤的衍生物设置效果：不能为上级召唤而解放
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
