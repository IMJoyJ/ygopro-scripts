--ディザスター・デーモン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：以自己以及对方场上的卡各1张为对象才能发动。那些卡破坏。这个效果把表侧表示的恶魔族怪兽破坏的场合，这张卡的攻击力直到回合结束时上升那些怪兽的原本攻击力合计数值的一半。
function c29603180.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：以自己以及对方场上的卡各1张为对象才能发动。那些卡破坏。这个效果把表侧表示的恶魔族怪兽破坏的场合，这张卡的攻击力直到回合结束时上升那些怪兽的原本攻击力合计数值的一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29603180,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,29603180)
	e1:SetTarget(c29603180.destg)
	e1:SetOperation(c29603180.desop)
	c:RegisterEffect(e1)
end
-- 目标选择函数：进行发动合法性检查（自己及对方场上各有至少1张可选卡），然后分别选择自己场上和对方场上的卡各1张作为对象，合并后用Duel.SetOperationInfo登记破坏信息。
function c29603180.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动合法性检查：确认自己场上存在至少1张可选为对象的卡，且对方场上也存在至少1张可选为对象的卡（对象可以是怪兽或魔陷等任意卡）。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,0,1,nil) and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向操作玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上的1张卡作为对象（从自己场上所有卡中选，不限种类）。
	local g1=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 向操作玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为对象（从对方场上所有卡中选，不限种类）。
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 将本次连锁的操作信息登记为“破坏2张卡”，供其他卡（如星尘龙等）进行效果发动检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 攻击力上升的筛选条件：被破坏的怪兽在被破坏前是表侧表示，且其在场上时的种族为恶魔族。
function c29603180.atkfilter(c)
	return c:IsPreviousPosition(POS_FACEUP) and bit.band(c:GetPreviousRaceOnField(),RACE_FIEND)~=0
end
-- 效果处理函数：取得连锁对象中仍与效果关联的卡并破坏；如果成功破坏且此卡仍表侧表示且与效果关联，则从实际被破坏的卡中筛选表侧表示恶魔族怪兽，计算其原本攻击力合计值的一半，为此卡附加攻击力上升效果。
function c29603180.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从当前连锁信息中取出发动时选择的对象卡组，并筛选出仍然与本次效果关联的卡（若对象已离场或不受该效果影响则被过滤掉）。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 判断条件：仍有可破坏的对象且实际破坏成功，并且此卡仍在场上表侧表示且效果未被无效；满足则继续执行攻击力上升处理。
	if tg:GetCount()>0 and Duel.Destroy(tg,REASON_EFFECT)~=0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 获取刚才破坏操作实际被破坏的所有卡片组，用于进一步筛选其中被破坏的恶魔族怪兽。
		local og=Duel.GetOperatedGroup()
		local ag=og:Filter(c29603180.atkfilter,nil)
		local atk=ag:GetSum(Card.GetTextAttack)/2
		-- 这个效果把表侧表示的恶魔族怪兽破坏的场合，这张卡的攻击力直到回合结束时上升那些怪兽的原本攻击力合计数值的一半。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
