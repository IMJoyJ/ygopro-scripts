--魔弾の悪魔 カスパール
-- 效果：
-- 包含恶魔族·光属性怪兽的怪兽2只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从手卡·卡组选包含怪兽的2张「魔弹」卡，那之内的1只怪兽在自己场上特殊召唤，另1张在对方场上盖放。
-- ②：只要这张卡在怪兽区域存在，自己·对方回合自己可以把「魔弹」魔法·陷阱卡从手卡发动。
local s,id,o=GetID()
-- 初始化卡片效果，设置连接召唤手续，注册连接召唤成功的诱发效果以及在对方回合/手卡发动「魔弹」魔陷的永续效果
function s.initial_effect(c)
	-- 添加连接召唤手续：包含恶魔族·光属性怪兽的怪兽2只
	aux.AddLinkProcedure(c,nil,2,2,s.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。从手卡·卡组选包含怪兽的2张「魔弹」卡，那之内的1只怪兽在自己场上特殊召唤，另1张在对方场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己·对方回合自己可以把「魔弹」魔法·陷阱卡从手卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"适用「魔弹恶魔 卡斯帕」的效果来发动"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e2:SetRange(LOCATION_MZONE)
	-- 设置永续效果适用对象为「魔弹」卡
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x108))
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetValue(32841045)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e3)
end
-- 检查连接素材中是否包含至少1只恶魔族·光属性怪兽
function s.lcheck(g)
	return g:IsExists(s.mfilter,1,nil)
end
-- 过滤恶魔族·光属性的连接素材怪兽
function s.mfilter(c)
	return c:IsLinkRace(RACE_FIEND) and c:IsLinkAttribute(ATTRIBUTE_LIGHT)
end
-- 判定卡片是否通过连接召唤成功
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤可以在对方场上盖放的「魔弹」卡（怪兽里侧守备特召或魔陷盖放）
function s.setfilter(c,e,tp)
	if c:IsType(TYPE_MONSTER) then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 判定对方主要怪兽区是否有空位
			and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp)
	else
		-- 判定对方魔法与陷阱区是否有空位或为场地魔法卡
		return (Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0
			or c:IsType(TYPE_FIELD))
			and c:IsSSetable(true)
	end
end
-- 过滤可以在自己场上表侧特殊召唤、且剩余卡中存在可在对方场上盖放的「魔弹」怪兽
function s.spfilter(c,g,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		and g:IsExists(s.setfilter,1,c,e,tp)
end
-- 检查选取的2张卡组合中是否存在可特召至己方且另1张可在对方场上盖放的合法组合
function s.gcheck(g,e,tp)
	return g:IsExists(s.spfilter,1,nil,g,e,tp)
end
-- ①效果的发动条件与目标设置：判定手卡·卡组中是否存在合法的2张「魔弹」卡组合
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取手卡·卡组中的所有「魔弹」卡
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_DECK+LOCATION_HAND,0,nil,0x108)
	-- 判定自己主要怪兽区是否有空余位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and g:CheckSubGroup(s.gcheck,2,2,e,tp) end
	-- 设置操作信息：从手卡·卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- ①效果的处理：选包含怪兽的2张「魔弹」卡，1只在自己场上特召，另1张在对方场上盖放
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区是否有空位，无空位则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取手卡·卡组中的所有「魔弹」卡
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_DECK+LOCATION_HAND,0,nil,0x108)
	if not g:CheckSubGroup(s.gcheck,2,2,e,tp) then return end
	-- 提示玩家选择要操作的2张「魔弹」卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local tg=g:SelectSubGroup(tp,s.gcheck,false,2,2,e,tp)
	if tg then
		-- 提示玩家选择要在自己场上特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=tg:FilterSelect(tp,s.spfilter,1,1,nil,tg,e,tp)
		tg:Sub(sg)
		-- 将选择的「魔弹」怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		local tc=tg:GetFirst()
		if tc:IsType(TYPE_MONSTER) then
			-- 将另1张怪兽卡在对方场上里侧守备表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
			-- 向己方玩家确认在对方场上盖放的怪兽
			Duel.ConfirmCards(tp,tc)
		else
			-- 将另1张魔法·陷阱卡在对方场上盖放
			Duel.SSet(tp,tc,1-tp)
		end
	end
end
