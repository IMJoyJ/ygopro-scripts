--ミレニアムーン・メイデン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合才能发动。这张卡当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ②：这张卡是当作永续魔法卡使用的状态，对方的效果发动的场合才能发动。这张卡特殊召唤，这个回合中，对方不能把自己场上的5星以上的幻想魔族·魔法师族怪兽作为效果的对象。
-- ③：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
local s,id,o=GetID()
-- 初始化并注册该卡的三个效果：①手卡起动效果，将自身当作永续魔法卡放置到自己的魔陷区；②在魔陷区作为永续魔法卡状态且对方发动效果时特殊召唤自身，并让己方场上5星以上的幻想魔族·魔法师族怪兽本回合内不能成为对方效果对象；③自身与怪兽战斗时，那两只怪兽不会被那次战斗破坏。
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合才能发动。这张卡当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"当作魔法卡放置"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡是当作永续魔法卡使用的状态，对方的效果发动的场合才能发动。这张卡特殊召唤，这个回合中，对方不能把自己场上的5星以上的幻想魔族·魔法师族怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件判定函数：在发动时检查自己魔陷区是否有空位，为空则允许发动。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动①前的合法性检查：若自己魔陷区存在可用空格，则效果可以发动（chk==0为发动时的判定）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
-- ①效果处理：将这张卡从手卡移动到自己的魔陷区表侧表示放置，并给它附加变成永续魔法卡的效果，使其在魔陷区作为永续魔法卡使用。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试将这张卡移动到自己的魔陷区表侧表示放置；仅当移动成功时才继续赋予其永续魔法卡类型。
	if Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		-- 这张卡当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
	end
end
-- ②的发动条件：这张卡在魔陷区且类型为永续魔法卡（即处于当作永续魔法卡使用的状态），并且对方发动了效果（rp≠tp）时满足。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetType()==TYPE_SPELL+TYPE_CONTINUOUS and rp~=tp
end
-- ②的发动目标与合法性检查：确认自己主要怪兽区有空位，且能够按指定参数（卡名id、等级4、光属性、幻想魔族、攻1500/守1300的怪兽）特殊召唤这张卡；满足时登记特殊召唤信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ②发动前的合法性检查：自己主要怪兽区有空位，且当前玩家能够特殊召唤这张卡（卡名id、等级4、光属性、幻想魔族、攻1500/守1300）时允许发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1ae,TYPE_MONSTER+TYPE_EFFECT,1500,1300,4,RACE_ILLUSION,ATTRIBUTE_LIGHT) end
	-- 登记本次连锁的操作信息：本效果将进行特殊召唤（对象为本卡，数量1），以便其他卡牌进行链锁或响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：将这张卡特殊召唤；成功后给己方场上5星以上的幻想魔族·魔法师族怪兽附加‘不能成为对方效果对象’的领域效果，并注册客户端提示效果显示‘效果适用中’。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与发动效果相关且特殊召唤成功（返回值不等于0）后，才为后续保护效果进行注册。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个回合中，对方不能把自己场上的5星以上的幻想魔族·魔法师族怪兽作为效果的对象。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(s.efftg)
		-- 设定‘不能成为效果对象’的值函数为aux.tgoval，即只有效果使用者是对方玩家时返回true，用于使保护仅针对对方效果。
		e1:SetValue(aux.tgoval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将己方场上的‘不能成为对方效果对象’的领域效果注册到游戏中，持续到回合结束。
		Duel.RegisterEffect(e1,tp)
		-- 这个回合中，对方不能把自己场上的5星以上的幻想魔族·魔法师族怪兽作为效果的对象。
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,2))  --"「千年月光少女」效果适用中"
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetTargetRange(1,0)
		-- 注册一个仅用于客户端提示的领域效果，向己方玩家显示‘千年月光少女’②的保护效果正在适用的提示，持续到回合结束。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 判定‘不能成为效果对象’的保护目标：等级5以上，且种族为幻想魔族或魔法师族的怪兽。
function s.efftg(e,c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_ILLUSION+RACE_SPELLCASTER)
end
-- 判定‘不会被那次战斗破坏’的对象：这张卡自身以及这张卡的战斗对象（即互相战斗的两只怪兽）。
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
