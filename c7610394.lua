--眷現の呪眼
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：在自己场上把1只「咒眼之眷属衍生物」（恶魔族·暗·1星·攻/守400）特殊召唤。自己的魔法与陷阱区域有「太阴之咒眼」存在的场合，这个效果特殊召唤的数量可以变成2只。这张卡的发动后，直到回合结束时自己不是恶魔族怪兽不能特殊召唤。
-- ②：把墓地的这张卡除外才能发动。这个回合，自己场上的「咒眼」魔法·陷阱卡不会成为对方的效果的对象。
function c7610394.initial_effect(c)
	-- ①：在自己场上把1只「咒眼之眷属衍生物」（恶魔族·暗·1星·攻/守400）特殊召唤。自己的魔法与陷阱区域有「太阴之咒眼」存在的场合，这个效果特殊召唤的数量可以变成2只。这张卡的发动后，直到回合结束时自己不是恶魔族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7610394,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,7610394)
	e1:SetTarget(c7610394.target)
	e1:SetOperation(c7610394.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。这个回合，自己场上的「咒眼」魔法·陷阱卡不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7610394,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,7610395)
	-- 把墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c7610394.imop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的「太阴之咒眼」
function c7610394.filter(c)
	return c:IsFaceup() and c:IsCode(44133040)
end
-- ①效果的发动准备与合法性检测
function c7610394.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测玩家是否可以特殊召唤「咒眼之眷属衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,7610395,0x129,TYPES_TOKEN_MONSTER,400,400,1,RACE_FIEND,ATTRIBUTE_DARK) end
	-- 设置连锁处理中的操作信息为特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 设置连锁处理中的操作信息为产生1个衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
-- ①效果的特殊召唤处理与誓约效果注册
function c7610394.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域空格数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local flag=false
	-- 如果满足特殊召唤1只衍生物的条件
	if ft>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,7610395,0x129,TYPES_TOKEN_MONSTER,400,400,1,RACE_FIEND,ATTRIBUTE_DARK) then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if ft>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 且自己的魔法与陷阱区域存在「太阴之咒眼」
			and Duel.IsExistingMatchingCard(c7610394.filter,tp,LOCATION_SZONE,0,1,nil)
			-- 询问玩家是否选择特殊召唤2只衍生物
			and Duel.SelectYesNo(tp,aux.Stringid(7610394,2)) then  --"是否特殊召唤2只？"
			flag=true
		end
		-- 创建第1只「咒眼之眷属衍生物」
		local token=Duel.CreateToken(tp,7610395)
		-- 将第1只衍生物以表侧表示特殊召唤
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		if flag==true then
			-- 创建第2只「咒眼之眷属衍生物」
			local token=Duel.CreateToken(tp,7610395)
			-- 将第2只衍生物以表侧表示特殊召唤
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 完成特殊召唤的最终处理
		Duel.SpecialSummonComplete()
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不是恶魔族怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c7610394.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 给玩家注册不能特殊召唤恶魔族以外怪兽的限制效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制条件：不能特殊召唤非恶魔族的怪兽
function c7610394.splimit(e,c)
	return not c:IsRace(RACE_FIEND)
end
-- ②效果的抗性赋予处理
function c7610394.imop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己场上的「咒眼」魔法·陷阱卡不会成为对方的效果的对象。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(c7610394.imlimit)
	-- 设置抗性为不会成为对方的效果对象
	e1:SetValue(aux.tgoval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册使场上特定卡片获得对象抗性的效果
	Duel.RegisterEffect(e1,tp)
end
-- 抗性适用对象：自己场上表侧表示的「咒眼」魔法·陷阱卡
function c7610394.imlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x129) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
