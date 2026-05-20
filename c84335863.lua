--白薔薇の回廊
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上没有怪兽存在的场合才能发动。从手卡把1只「蔷薇龙」怪兽或者植物族怪兽特殊召唤。
-- ②：自己抽卡阶段的抽卡前，宣言卡的种类（怪兽·魔法·陷阱）才能发动。自己卡组最上面的卡给双方确认，宣言的种类的卡的场合，这个回合中，以下效果适用。
-- ●自己场上的7星以上的同调怪兽的攻击力上升1000。
function c84335863.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己场上没有怪兽存在的场合才能发动。从手卡把1只「蔷薇龙」怪兽或者植物族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84335863,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,84335863)
	e2:SetCondition(c84335863.spcon)
	e2:SetTarget(c84335863.sptg)
	e2:SetOperation(c84335863.spop)
	c:RegisterEffect(e2)
	-- ②：自己抽卡阶段的抽卡前，宣言卡的种类（怪兽·魔法·陷阱）才能发动。自己卡组最上面的卡给双方确认，宣言的种类的卡的场合，这个回合中，以下效果适用。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(84335863,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PREDRAW)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(c84335863.cfcon)
	e3:SetTarget(c84335863.cftg)
	e3:SetOperation(c84335863.cfop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件判定函数（自己场上没有怪兽存在）
function c84335863.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤手牌中可以特殊召唤的「蔷薇龙」怪兽或植物族怪兽
function c84335863.spfilter(c,e,tp)
	return (c:IsSetCard(0x1123) or c:IsRace(RACE_PLANT)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备与合法性检测函数
function c84335863.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足条件的怪兽
		and Duel.IsExistingMatchingCard(c84335863.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息为从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果的实际处理函数（从手牌特殊召唤怪兽）
function c84335863.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上没有可用的怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c84335863.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件判定函数（自己回合的抽卡阶段且卡组有卡存在）
function c84335863.cfcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己的回合，且自己卡组有至少1张卡
	return Duel.GetTurnPlayer()==tp and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
end
-- ②效果的发动准备与宣言卡片种类处理
function c84335863.cftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家选择卡片的种类
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 让玩家宣言一个卡片种类（怪兽·魔法·陷阱），并将结果保存在效果的Label中
	e:SetLabel(Duel.AnnounceType(tp))
end
-- ②效果的实际处理函数（确认卡组最上方的卡并适用攻击力上升效果）
function c84335863.cfop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己卡组没有卡则不处理
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=0 then return end
	-- 给双方确认自己卡组最上面的一张卡
	Duel.ConfirmDecktop(tp,1)
	-- 获取自己卡组最上面的一张卡
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	local opt=e:GetLabel()
	if (opt==0 and tc:IsType(TYPE_MONSTER)) or (opt==1 and tc:IsType(TYPE_SPELL)) or (opt==2 and tc:IsType(TYPE_TRAP)) then
		-- ●自己场上的7星以上的同调怪兽的攻击力上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetValue(1000)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(c84335863.atktg)
		-- 注册该回合内适用的攻击力上升效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 攻击力上升效果的适用对象过滤函数（自己场上表侧表示的7星以上的同调怪兽）
function c84335863.atktg(e,c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsType(TYPE_SYNCHRO)
end
