--黒き覚醒のエルドリクシル
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从手卡·卡组把1只不死族怪兽守备表示特殊召唤。自己场上没有「黄金国巫妖」怪兽存在的场合，这个效果不是「黄金国巫妖」怪兽不能特殊召唤。这张卡的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从卡组把1张「黄金乡」魔法·陷阱卡在自己场上盖放。
function c68829754.initial_effect(c)
	-- ①：从手卡·卡组把1只不死族怪兽守备表示特殊召唤。自己场上没有「黄金国巫妖」怪兽存在的场合，这个效果不是「黄金国巫妖」怪兽不能特殊召唤。这张卡的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68829754,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,68829754)
	e1:SetTarget(c68829754.target)
	e1:SetOperation(c68829754.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从卡组把1张「黄金乡」魔法·陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68829754,1))  --"盖放魔陷"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,68829754)
	-- 把墓地的这张卡除外作为发动效果的Cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c68829754.settg)
	e2:SetOperation(c68829754.setop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「黄金国巫妖」怪兽
function c68829754.filter(c)
	return c:IsSetCard(0x1142) and c:IsFaceup()
end
-- 过滤条件：手卡·卡组中可以特殊召唤的不死族怪兽（若场上没有「黄金国巫妖」怪兽，则必须是「黄金国巫妖」怪兽）
function c68829754.spfilter(c,e,tp,check)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and (check or c:IsSetCard(0x1142))
end
-- 效果①的发动准备与合法性检测
function c68829754.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己场上是否存在表侧表示的「黄金国巫妖」怪兽
		local chk1=Duel.IsExistingMatchingCard(c68829754.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己场上是否有空余的怪兽区域
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查手卡·卡组中是否存在满足特殊召唤条件的不死族怪兽
			and Duel.IsExistingMatchingCard(c68829754.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,chk1)
	end
	-- 设置连锁处理中的操作信息：从手卡·卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果①的处理：特殊召唤怪兽，并适用“直到回合结束时自己不是不死族怪兽不能特殊召唤”的限制
function c68829754.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时场上没有空余的怪兽区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查自己场上是否存在表侧表示的「黄金国巫妖」怪兽
	local chk1=Duel.IsExistingMatchingCard(c68829754.filter,tp,LOCATION_MZONE,0,1,nil)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡·卡组选择1只满足条件的不死族怪兽
	local g=Duel.SelectMatchingCard(tp,c68829754.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,chk1)
	if #g>0 then
		-- 将选择的怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。②：把墓地的这张卡除外才能发动。从卡组把1张「黄金乡」魔法·陷阱卡在自己场上盖放。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c68829754.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册该限制效果，使其对玩家生效
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制条件：不能特殊召唤非不死族的怪兽
function c68829754.splimit(e,c)
	return not c:IsRace(RACE_ZOMBIE)
end
-- 过滤条件：卡组中可以盖放的「黄金乡」魔法·陷阱卡
function c68829754.stfilter(c)
	return c:IsSetCard(0x143) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 效果②的发动准备与合法性检测
function c68829754.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的魔法·陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在可盖放的「黄金乡」魔法·陷阱卡
		and Duel.IsExistingMatchingCard(c68829754.stfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果②的处理：从卡组将1张「黄金乡」魔法·陷阱卡盖放到场上
function c68829754.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时场上没有空余的魔法·陷阱区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 玩家从卡组选择1张满足条件的「黄金乡」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c68829754.stfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡在自己场上盖放
		Duel.SSet(tp,g)
	end
end
