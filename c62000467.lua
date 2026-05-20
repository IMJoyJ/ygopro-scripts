--剣闘獣ドラガシス
-- 效果：
-- 「剑斗兽」怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己的「剑斗兽」怪兽攻击的场合，那只怪兽不会被那次战斗破坏，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者的额外卡组才能发动。从卡组把2只「剑斗兽」怪兽特殊召唤（同名卡最多1张）。
function c62000467.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤手续，需要2只「剑斗兽」怪兽作为素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x1019),2,2)
	-- ①：自己的「剑斗兽」怪兽攻击的场合，那只怪兽不会被那次战斗破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c62000467.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(1)
	e2:SetCondition(c62000467.actcon)
	c:RegisterEffect(e2)
	-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者的额外卡组才能发动。从卡组把2只「剑斗兽」怪兽特殊召唤（同名卡最多1张）。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(62000467,0))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,62000467)
	e6:SetCondition(c62000467.spcon)
	e6:SetCost(c62000467.spcost)
	e6:SetTarget(c62000467.sptg)
	e6:SetOperation(c62000467.spop)
	c:RegisterEffect(e6)
end
-- 战斗破坏抗性效果的适用对象筛选函数
function c62000467.indtg(e,c)
	-- 检查目标怪兽是否为「剑斗兽」且为当前攻击怪兽
	return c:IsSetCard(0x1019) and Duel.GetAttacker()==c
end
-- 封锁对方效果发动效果的适用条件函数
function c62000467.actcon(e)
	-- 获取当前进行攻击的怪兽
	local tc=Duel.GetAttacker()
	local tp=e:GetHandlerPlayer()
	return tc and tc:IsControler(tp) and tc:IsSetCard(0x1019)
end
-- 特殊召唤效果的发动条件函数（这张卡进行了战斗）
function c62000467.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 特殊召唤效果的发动代价函数
function c62000467.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	-- 作为发动代价，将自身送回持有者的额外卡组
	Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_COST)
end
-- 过滤卡组中可以特殊召唤的「剑斗兽」怪兽
function c62000467.spfilter(c,e,tp)
	return c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备与检测函数
function c62000467.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取当前玩家场上可用的怪兽区域空格数
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if e:GetHandler():GetSequence()<5 then ft=ft+1 end
		-- 获取卡组中所有满足特殊召唤条件的「剑斗兽」怪兽
		local g=Duel.GetMatchingGroup(c62000467.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return ft>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			and g:GetClassCount(Card.GetCode)>=2
	end
	-- 设置连锁的操作信息，表示该效果将从卡组特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 特殊召唤效果的处理函数
function c62000467.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查当前玩家场上的怪兽区域空格数是否足够（至少需要2个空位），不足则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 重新获取卡组中所有满足特殊召唤条件的「剑斗兽」怪兽
	local g=Duel.GetMatchingGroup(c62000467.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>=2 and g:GetClassCount(Card.GetCode)>=2 then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从符合条件的卡片中选择2只卡名不同的怪兽
		local sg1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
		local tc=sg1:GetFirst()
		-- 准备将第一只选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
		tc=sg1:GetNext()
		-- 准备将第二只选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
		-- 完成所有准备好的怪兽的特殊召唤
		Duel.SpecialSummonComplete()
	end
end
