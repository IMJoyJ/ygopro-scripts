--魔弾の悪魔 カスパール
-- 效果：
-- 包含恶魔族·光属性怪兽的怪兽2只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从手卡·卡组选包含怪兽的2张「魔弹」卡，那之内的1只怪兽在自己场上特殊召唤，另1张在对方场上盖放。
-- ②：只要这张卡在怪兽区域存在，自己·对方回合自己可以把「魔弹」魔法·陷阱卡从手卡发动。
local s,id,o=GetID()
-- 为「魔弹恶魔 卡斯帕」注册连接召唤手续、苏生限制，并注册①的诱发效果以及②的让「魔弹」魔法·陷阱卡可在双方回合从手牌发动的永续效果（分别对应魔法和陷阱两个效果）。
function s.initial_effect(c)
	-- 为这张卡添加连接召唤手续：需要2只怪兽作为连接素材，且素材组中必须包含1只恶魔族·光属性的连接怪兽（由s.lcheck判定）。
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
	-- 将②效果的适用对象限定为手牌中持有「魔弹」字段（0x108）的卡，即只有「魔弹」卡才能被允许从手牌发动。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x108))
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetValue(32841045)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e3)
end
-- 检查连接素材组g中是否存在至少1只满足s.mfilter的怪兽，确保连接召唤素材满足“包含恶魔族·光属性怪兽的怪兽2只”的条件。
function s.lcheck(g)
	return g:IsExists(s.mfilter,1,nil)
end
-- 判定素材怪兽是否为恶魔族·光属性的连接怪兽（同时检查连接怪兽的种族和属性）。
function s.mfilter(c)
	return c:IsLinkRace(RACE_FIEND) and c:IsLinkAttribute(ATTRIBUTE_LIGHT)
end
-- ①效果的发动条件：只有这张卡以连接召唤方式特殊召唤成功时才能发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 判定要放到对方场上的另一张「魔弹」卡是否可行：若为怪兽，需要对方主怪兽区有空位且该怪兽能被特殊召唤到对方场上（并避开青眼精灵龙的“不能2只以上同时特殊召唤”限制）；若为魔法·陷阱，需要对方魔陷区有空位（场地魔法可盖到场地魔法区）且该卡可以被盖放。
function s.setfilter(c,e,tp)
	if c:IsType(TYPE_MONSTER) then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 检查对方场上是否有可用的主怪兽区，用于将另一张怪兽卡里侧守备表示特殊召唤到对方场上。
			and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp)
	else
		-- 检查对方场上是否有可用的魔陷区，用于将另一张魔法·陷阱卡盖放到对方魔陷区；场地魔法不受此限制。
		return (Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0
			or c:IsType(TYPE_FIELD))
			and c:IsSSetable(true)
	end
end
-- 判定某张「魔弹」卡是否可以作为自己要特殊召唤的怪兽：它自己能表侧表示特殊召唤，且剩下的另一张卡能满足“放到对方场上”的条件。
function s.spfilter(c,g,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		and g:IsExists(s.setfilter,1,c,e,tp)
end
-- 判定2张「魔弹」卡的组合是否可行：其中至少1张可作为自己场上特殊召唤的怪兽，另一张可满足对方场上盖放/特殊召唤的条件。
function s.gcheck(g,e,tp)
	return g:IsExists(s.spfilter,1,nil,g,e,tp)
end
-- ①效果的发动时点：从手卡·卡组中寻找满足条件的2张「魔弹」卡组合，并确认自己主怪兽区有空位；chk==0时仅做合法性检查。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取自己手卡·卡组中所有「魔弹」字段（0x108）的卡，作为选择对象。
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_DECK+LOCATION_HAND,0,nil,0x108)
	-- 发动合法性检查：自己场上必须存在可用的主怪兽区（用于特殊召唤），且存在满足条件的2张「魔弹」卡组合。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and g:CheckSubGroup(s.gcheck,2,2,e,tp) end
	-- 向系统登记本次效果将进行1次特殊召唤，且特殊召唤对象从手卡·卡组选出（供相关卡的效果连锁判断使用）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果处理：从手卡·卡组选择2张「魔弹」卡，玩家选择其中1只怪兽表侧表示特殊召唤到自己场上；剩下那张若为怪兽则里侧守备表示特殊召唤到对方场上并给对方确认，若为魔法·陷阱则盖放到对方魔陷区。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理开始时再次确认自己主怪兽区是否还有空位，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果处理时重新从手卡·卡组获取所有「魔弹」卡（因为发动后卡组可能变化）。
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_DECK+LOCATION_HAND,0,nil,0x108)
	if not g:CheckSubGroup(s.gcheck,2,2,e,tp) then return end
	-- 提示玩家选择要处理的2张「魔弹」卡（作为效果对象）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local tg=g:SelectSubGroup(tp,s.gcheck,false,2,2,e,tp)
	if tg then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=tg:FilterSelect(tp,s.spfilter,1,1,nil,tg,e,tp)
		tg:Sub(sg)
		-- 将选中的1只「魔弹」怪兽表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		local tc=tg:GetFirst()
		if tc:IsType(TYPE_MONSTER) then
			-- 将剩下的1张「魔弹」怪兽卡里侧守备表示特殊召唤到对方场上。
			Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
			-- 向自己玩家展示那张被特殊召唤到对方场上的里侧怪兽，使其信息对双方确认。
			Duel.ConfirmCards(tp,tc)
		else
			-- 将剩下的1张非怪兽「魔弹」卡（魔法·陷阱）盖放到对方魔陷区。
			Duel.SSet(tp,tc,1-tp)
		end
	end
end
