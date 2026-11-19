--影帽子
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这张卡发动后变成持有以下效果的效果怪兽（幻想魔族·暗·4星·攻1500/守600）在怪兽区域特殊召唤（也当作陷阱卡使用）。
-- ●这张卡特殊召唤的场合，以最多有自己场上的幻想魔族怪兽数量的对方场上的表侧表示卡为对象才能发动。那些卡的效果直到回合结束时无效。
-- ●这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
local s,id,o=GetID()
-- 初始化卡片效果，为这张卡注册陷阱卡发动及怪兽化特招效果(e1)、特招场合无效对方表侧卡效果(e2)以及战斗不破坏的永续效果(e3)
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：这张卡发动后变成持有以下效果的效果怪兽（幻想魔族·暗·4星·攻1500/守600）在怪兽区域特殊召唤（也当作陷阱卡使用）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ●这张卡特殊召唤的场合，以最多有自己场上的幻想魔族怪兽数量的对方场上的表侧表示卡为对象才能发动。那些卡的效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.con)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	-- ●这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCondition(s.con)
	e3:SetTarget(s.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- ①效果的Target函数，检测发动时cost校验、怪兽区空格及能否作为陷阱怪兽特殊召唤，并设置特殊召唤操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否有可用的怪兽区域空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己是否能将这张卡作为4星·幻想魔族·暗属性·攻1500/守600的效果陷阱怪兽特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,1500,600,4,RACE_ILLUSION,ATTRIBUTE_DARK) end
	-- 设置操作信息，声明将对这张卡进行特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的Operation函数，再次确认能否作为陷阱怪兽特招后，为这张卡追加效果怪兽与陷阱属性并特殊召唤到怪兽区
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时若玩家无法将该参数的陷阱怪兽特殊召唤则终止处理
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,1500,600,4,RACE_ILLUSION,ATTRIBUTE_DARK) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 以自身效果特殊召唤的标识(SUMMON_VALUE_SELF)将这张卡无视召唤条件以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- Condition函数，检查这张卡是否是通过自身效果(SUMMON_VALUE_SELF)特殊召唤到场上的
function s.con(e)
	local c=e:GetHandler()
	return c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 过滤函数，筛选表侧表示的幻想魔族怪兽
function s.filter(c)
	return c:IsRace(RACE_ILLUSION) and c:IsFaceup()
end
-- 无效效果的Target函数，统计自己场上表侧幻想魔族怪兽数量并选择最多该数量的对方场上表侧表示卡作为对象
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 计算自己怪兽区域中表侧表示的幻想魔族怪兽数量
	local ct=Duel.GetFieldGroup(tp,LOCATION_MZONE,0):FilterCount(s.filter,nil)
	-- 对象校验时，检查对象卡是否为对方场上表侧表示且可被无效效果的卡
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and aux.NegateAnyFilter(chkc) end
	if chk==0 then return e:GetHandler():IsLocation(LOCATION_MZONE)
		-- 检查对方场上是否存在至少1张可被无效的表侧卡作为对象，且自己场上的幻想魔族怪兽数量大于0
		and Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) and ct>0 end
	-- 向自己发送选择提示信息：“请选择要无效的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让自己在对方场上选择1到ct张可被无效的表侧表示卡作为连锁对象
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置操作信息，声明将无效所选对象卡g的全部效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 无效效果的Operation函数，遍历所有关联的对象卡并为其赋予直到回合结束时无效的效果
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中依然与效果保持关联的所有对象卡组
	local tg=Duel.GetTargetsRelateToChain()
	-- 遍历对象卡组tg中的每一张卡tc
	for tc in aux.Next(tg) do
		if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
			-- 使与对象卡tc在当前连锁中相关的效果发动处理无效化
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 那些卡的效果直到回合结束时无效。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 那些卡的效果直到回合结束时无效。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				-- 那些卡的效果直到回合结束时无效。
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
		end
	end
end
-- 战斗不破坏的Target过滤函数，筛选出这张卡自身以及正在与这张卡进行战斗的对方怪兽
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
