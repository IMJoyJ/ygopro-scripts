--ナイトメア・アイズ・サクリファイス
-- 效果：
-- 种族不同的恶魔族·幻想魔族·魔法师族怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合或者这张卡进行战斗的战斗阶段结束时才能发动。对方场上1只怪兽当作装备魔法卡使用给这张卡装备。
-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值。
-- ③：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
-- ④：对方怪兽不能向其他怪兽攻击。
local s,id,o=GetID()
-- 为这张卡添加苏生限制和融合召唤手续，并注册全部效果：①在特殊召唤成功或战斗阶段结束时可将对方1只怪兽装备给自己；②攻击力上升效果装备的怪兽攻击力；③与怪兽战斗时双方不被战破；④对方怪兽只能攻击这张卡。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：用2只满足s.ffilter条件的怪兽（种族属于恶魔族/幻想魔族/魔法师族且种族互不相同）作为融合素材。
	aux.AddFusionProcFunRep(c,s.ffilter,2,true)
	-- ①：这张卡特殊召唤的场合或者这张卡进行战斗的战斗阶段结束时才能发动。对方场上1只怪兽当作装备魔法卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"装备"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.eqcon)
	c:RegisterEffect(e2)
	-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	-- ③：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(s.indtg)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- ④：对方怪兽不能向其他怪兽攻击。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e5:SetValue(s.atlimit)
	c:RegisterEffect(e5)
end
-- 辅助判断函数：任何怪兽都可以被本卡当作装备卡使用（恒返回true）；实际进一步的筛选由s.eqfilter完成。
function s.can_equip_monster(c)
	return true
end
-- 战斗阶段结束时装备效果的发动条件：这张卡本回合进行过战斗（存在战斗过的怪兽）。
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 融合素材筛选：怪兽必须是恶魔族/幻想魔族/魔法师族之一，且与已选素材种族不同（保证种族不同）。
function s.ffilter(c,fc,sub,mg,sg)
	return c:IsRace(RACE_ILLUSION+RACE_SPELLCASTER+RACE_FIEND) and (not sg or not sg:IsExists(Card.IsRace,1,c,c:GetRace()))
end
-- 装备筛选：对方场上能变更控制权且（里侧表示可不检查限制，或不是禁止卡且不违反同名卡唯一限制）的怪兽可作为装备对象。
function s.eqfilter(c,tp)
	return c:IsAbleToChangeControler() and (c:IsFacedown() or not c:IsForbidden() and c:CheckUniqueOnField(tp))
end
-- 定义①效果的发动目标函数：进行发动合法性与后续处理信息的设定（具体检查见下）。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动时（chk==0）检查对方场上是否存在至少1只满足s.eqfilter条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.eqfilter,tp,0,LOCATION_MZONE,1,nil,tp)
		-- 并且自己魔陷区存在可用空位，以满足将选择的怪兽作为装备卡放置。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	-- 设置效果处理时的操作信息：宣告将把对方场上1只怪兽当作装备卡使用（CATEGORY_EQUIP）。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,1-tp,LOCATION_MZONE)
end
-- ①效果的发动处理：确认条件满足后，让玩家选择对方场上1只可装备怪兽，并将其装备给这张卡。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时确认这张卡仍与发动连锁相关、表侧表示且自己后场有空位，防止因卡离场或格子不足导致装备失败。
	if c:IsRelateToChain() and c:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 给操作玩家显示“请选择要装备的卡”的选择提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从对方场上选择1只满足s.eqfilter并可供装备的怪兽。
		local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
		if g:GetCount()>0 then
			-- 将被选择的卡展示选中动画，并记录这些卡为效果对象（建立连锁关联）。
			Duel.HintSelection(g)
			local sc=g:GetFirst()
			s.equip_monster(c,tp,sc)
		end
	end
end
-- 实际装备操作：将选中的怪兽作为装备卡装备给本卡，并为其注册装备对象限制效果和本卡效果装备标记。
function s.equip_monster(c,tp,tc)
	-- 如果存在目标怪兽且Duel.Equip成功将其作为装备卡装备给这张卡（保持原表示形式），则继续设置限制。
	if tc and Duel.Equip(tp,tc,c,false) then
		-- 对方场上1只怪兽当作装备魔法卡使用给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
	end
end
-- 装备限制判定：这张装备卡只能装备给e:GetOwner()（即本卡），防止被转移到其他怪兽身上。
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
-- ②效果攻击力上升值的计算：遍历本卡装备区的卡，只累计通过本卡效果装备的、表侧表示且拥有攻击力的怪兽卡（带FlagEffect标记）的攻击力。
function s.atkval(e,c)
	local atk=0
	local g=c:GetEquipGroup()
	local tc=g:GetFirst()
	while tc do
		if tc:GetFlagEffect(id)~=0 and tc:IsFaceup() and tc:GetTextAttack()>=0 and tc:GetOriginalType()&TYPE_MONSTER~=0 then
			atk=atk+tc:GetTextAttack()
		end
		tc=g:GetNext()
	end
	return atk
end
-- ③效果的对象判定：本卡与其战斗对象（BattleTarget）都不会被那次战斗破坏。
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- ④效果的限制：对方怪兽选择攻击对象时，不能选择除这张卡以外的怪兽（即只能攻击这张卡）。
function s.atlimit(e,c)
	return c~=e:GetHandler()
end
