--天魔の聲選器－『ヴァルモニカ』
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「异响鸣」怪兽加入手卡。
-- ②：自己的灵摆区域的卡有响鸣指示物被放置，那卡的响鸣指示物变成3个的场合，以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。这个效果得到控制权的怪兽不能攻击宣言。
local s,id,o=GetID()
-- 初始化函数，注册两个效果：e1为场地魔法的发动效果（检索卡组并加入手卡，含1回合1张的发动誓约限制），e2为场地区发动的诱发选发的改变控制权效果（取对象，1回合1次）
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从卡组把1只「异响鸣」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己的灵摆区域的卡有响鸣指示物被放置，那卡的响鸣指示物变成3个的场合，以对方场上1只怪兽为对象才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(s.concon)
	e2:SetTarget(s.contg)
	e2:SetOperation(s.conop)
	c:RegisterEffect(e2)
end
s.mentioned_counter={
	[0x6a]=true,
}
-- 定义检索用过滤函数：卡片属于「异响鸣」系列、是怪兽卡且可以加入手卡
function s.filter(c)
	return c:IsSetCard(0x1a3) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果处理：检索卡组中可加入手卡的「异响鸣」怪兽，存在时询问玩家是否执行，选是则让玩家选1只加入手卡并向对方展示
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从自己的卡组检索满足条件的「异响鸣」怪兽
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	-- 若卡组中存在可加入手卡的「异响鸣」怪兽，则询问玩家是否将其加入手卡
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否从卡组把1只「异响鸣」怪兽加入手卡？"
		-- 向玩家发送选卡提示：请选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的怪兽以效果原因加入玩家手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的这张卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- ②效果的发动条件：响鸣指示物是放置在自己的灵摆区域的卡上（事件的玩家是自己）
function s.concon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- ②效果取对象检查：再选择对象时，确认该卡是对方场上的怪兽且可以改变控制权
function s.contg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)
		and chkc:IsControlerCanBeChanged() end
	-- 发动可行性检查：对方场上存在可以改变控制权且能成为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选卡提示：请选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只可以改变控制权的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本连锁的操作信息：确定要处理改变对方场上1只怪兽控制权的分类
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- ②效果处理：取得对象怪兽，若其仍与效果关联则得到其控制权直到结束阶段，并赋予该怪兽直到结束阶段不能攻击宣言的永续效果
function s.conop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与本效果关联，则得到其控制权直到结束阶段，成功则继续后续处理
	if tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp,PHASE_END,1)>0 then
		-- 这个效果得到控制权的怪兽不能攻击宣言。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
