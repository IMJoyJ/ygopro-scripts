--ドン・サウザンドの玉座
-- 效果：
-- 对方的结束阶段时，自己回复那个回合受到战斗伤害的次数×500基本分。此外，自己场上的名字带有「混沌No.」以外的「No.」的怪兽成为攻击对象时，可以通过把这张卡送去墓地让那次攻击无效。那之后，把持有和那只自己怪兽相同「No.」数字的名字带有「混沌No.」的怪兽在那只怪兽上面重叠当作超量召唤从额外卡组特殊召唤。「上千主上的玉座」在自己场上只能有1张表侧表示存在。
function c93238626.initial_effect(c)
	c:SetUniqueOnField(1,0,93238626)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 对方的结束阶段时，自己回复那个回合受到战斗伤害的次数×500基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93238626,0))  --"回复"
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c93238626.reccon)
	e2:SetTarget(c93238626.rectg)
	e2:SetOperation(c93238626.recop)
	c:RegisterEffect(e2)
	-- 此外，自己场上的名字带有「混沌No.」以外的「No.」的怪兽成为攻击对象时，可以通过把这张卡送去墓地让那次攻击无效。那之后，把持有和那只自己怪兽相同「No.」数字的名字带有「混沌No.」的怪兽在那只怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(93238626,1))  --"攻击无效特殊召唤"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetCondition(c93238626.spcon)
	e3:SetCost(c93238626.spcost)
	e3:SetTarget(c93238626.sptg)
	e3:SetOperation(c93238626.spop)
	c:RegisterEffect(e3)
	if not c93238626.global_check then
		c93238626.global_check=true
		-- 对方的结束阶段时，自己回复那个回合受到战斗伤害的次数×500基本分。此外，自己场上的名字带有「混沌No.」以外的「No.」的怪兽成为攻击对象时，可以通过把这张卡送去墓地让那次攻击无效。那之后，把持有和那只自己怪兽相同「No.」数字的名字带有「混沌No.」的怪兽在那只怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DAMAGE)
		ge1:SetOperation(c93238626.checkop)
		-- 注册全局环境效果，用于记录玩家受到的战斗伤害次数
		Duel.RegisterEffect(ge1,0)
	end
end
-- 战斗伤害发生时的记录函数，为受到伤害的玩家注册一个回合内有效的标识效果
function c93238626.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 为受到战斗伤害的玩家注册一个持续到回合结束的标识效果，用以累计受到战斗伤害的次数
	Duel.RegisterFlagEffect(ep,93238626,RESET_PHASE+PHASE_END,0,1)
end
-- 回复效果的发动条件函数
function c93238626.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否不是自己（即是否为对方的结束阶段）
	return Duel.GetTurnPlayer()~=tp
end
-- 回复效果的启动与目标选择函数
function c93238626.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己在这个回合受到战斗伤害的次数
	local ct=Duel.GetFlagEffect(tp,93238626)
	-- 设置当前效果的处理对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置连锁信息，表明此效果的处理为让玩家回复“受到战斗伤害次数×500”的基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct*500)
end
-- 回复效果的执行函数
function c93238626.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取自己在这个回合受到战斗伤害的次数
	local ct=Duel.GetFlagEffect(tp,93238626)
	-- 使目标玩家回复“受到战斗伤害次数×500”的基本分
	Duel.Recover(p,ct*500,REASON_EFFECT)
end
-- 攻击无效并特殊召唤效果的发动条件函数
function c93238626.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前被攻击的怪兽
	local at=Duel.GetAttackTarget()
	return at:IsFaceup() and at:IsControler(tp) and at:IsSetCard(0x48) and not at:IsSetCard(0x1048)
end
-- 攻击无效并特殊召唤效果的代价处理函数
function c93238626.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡送去墓地作为发动的代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤额外卡组中满足特殊召唤条件的「混沌No.」怪兽
function c93238626.filter(c,e,tp,mc,no)
	-- 检查卡片的No.数字是否与被攻击怪兽相同，且属于「混沌No.」系列，并确认被攻击怪兽可以作为其超量素材
	return aux.GetXyzNumber(c)==no and c:IsSetCard(0x1048) and mc:IsCanBeXyzMaterial(c)
		-- 检查该怪兽是否可以以超量召唤的方式特殊召唤，且额外卡组怪兽出场的区域有空位
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 攻击无效并特殊召唤效果的目标选择与启动函数
function c93238626.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取当前被攻击的怪兽
		local at=Duel.GetAttackTarget()
		-- 获取被攻击怪兽的No.数字
		local no=aux.GetXyzNumber(at)
		-- 确认被攻击怪兽具有No.数字，且满足必须作为超量素材的规则限制
		return no and aux.MustMaterialCheck(at,tp,EFFECT_MUST_BE_XMATERIAL)
			-- 检查额外卡组中是否存在至少1张满足特殊召唤条件的「混沌No.」怪兽
			and Duel.IsExistingMatchingCard(c93238626.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,at,no)
	end
	-- 设置连锁信息，表明此效果的处理包含从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 攻击无效并特殊召唤效果的执行函数
function c93238626.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效那次攻击，如果未能成功无效则不进行后续处理
	if not Duel.NegateAttack() then return end
	-- 获取被攻击的怪兽
	local tc=Duel.GetAttackTarget()
	-- 检查被攻击怪兽是否满足必须作为超量素材的规则限制，若不满足则不处理
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	-- 获取被攻击怪兽的No.数字
	local no=aux.GetXyzNumber(tc)
	if tc:IsFacedown() or not tc:IsRelateToBattle() or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) or not no then return end
	-- 向玩家提示选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1张持有相同No.数字的「混沌No.」怪兽
	local g=Duel.SelectMatchingCard(tp,c93238626.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,no)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将被攻击怪兽原本持有的超量素材重叠到新特殊召唤的怪兽下面
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将被攻击怪兽自身重叠到新特殊召唤的怪兽下面作为超量素材
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将选择的「混沌No.」怪兽以超量召唤的方式在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
