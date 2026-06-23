--ナイトメア・アイズ・サクリファイス
-- 效果：
-- 种族不同的恶魔族·幻想魔族·魔法师族怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合或者这张卡进行战斗的战斗阶段结束时才能发动。对方场上1只怪兽当作装备魔法卡使用给这张卡装备。
-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值。
-- ③：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
-- ④：对方怪兽不能向其他怪兽攻击。
local s,id,o=GetID()
-- 初始化卡片效果，启用融合召唤限制并添加融合召唤手续
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用2个满足条件的怪兽作为融合素材
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
-- 判断是否可以装备怪兽，始终返回true
function s.can_equip_monster(c)
	return true
end
-- 判断是否满足装备条件，当此卡参与过战斗时满足条件
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 融合召唤过滤函数，筛选种族为幻想魔族·魔法师族·恶魔族且不与已选种族重复的怪兽
function s.ffilter(c,fc,sub,mg,sg)
	return c:IsRace(RACE_ILLUSION+RACE_SPELLCASTER+RACE_FIEND) and (not sg or not sg:IsExists(Card.IsRace,1,c,c:GetRace()))
end
-- 装备过滤函数，筛选可被控制并满足唯一性条件的怪兽
function s.eqfilter(c,tp)
	return c:IsAbleToChangeControler() and (c:IsFacedown() or not c:IsForbidden() and c:CheckUniqueOnField(tp))
end
-- 装备效果的发动条件判断，检查是否有满足条件的怪兽和足够的装备区域
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有满足条件的对方怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.eqfilter,tp,0,LOCATION_MZONE,1,nil,tp)
		-- 检查是否有足够的装备区域
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	-- 设置连锁操作信息，提示将要装备一张对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,1-tp,LOCATION_MZONE)
end
-- 装备效果的处理函数，选择并装备对方怪兽
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查装备条件是否满足，包括此卡是否在连锁中、是否表侧表示、是否有装备区域
	if c:IsRelateToChain() and c:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要装备的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 选择满足条件的对方怪兽进行装备
		local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
		if g:GetCount()>0 then
			-- 显示被选中的怪兽作为装备对象
			Duel.HintSelection(g)
			local sc=g:GetFirst()
			s.equip_monster(c,tp,sc)
		end
	end
end
-- 装备怪兽的处理函数，执行装备并注册限制效果
function s.equip_monster(c,tp,tc)
	-- 执行装备操作，若成功则继续注册限制效果
	if tc and Duel.Equip(tp,tc,c,false) then
		-- 注册装备限制效果，确保装备怪兽只能被此卡装备
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
-- 装备限制效果的判断函数，确保只能装备给此卡
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 计算攻击力提升值，累加所有装备怪兽的攻击力
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
-- 战斗破坏无效效果的目标判定函数，判断是否为自身或战斗对象
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- 攻击限制效果的目标判定函数，限制对方怪兽不能攻击其他怪兽
function s.atlimit(e,c)
	return c~=e:GetHandler()
end
